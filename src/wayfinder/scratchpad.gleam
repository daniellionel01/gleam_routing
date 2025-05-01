import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleam/uri

pub fn validate(routes: List(Route(a, b))) -> Nil {
  case do_validate(routes) {
    Error(msg) -> panic as msg
    Ok(_) -> Nil
  }
}

pub fn do_validate(routes: List(Route(a, b))) -> Result(Nil, String) {
  routes
  |> list.try_each(fn(route) {
    let expected_param_count = case route.handler {
      Handler0(_) -> 0
      Handler1(_) -> 1
      Handler2(_) -> 2
    }
    let params = filter_params(route.path)
    let actual_count = list.length(params)

    case
      actual_count > expected_param_count,
      actual_count < expected_param_count
    {
      True, _ -> Error("too many parameters: " <> path_to_string(route.path))
      _, True -> Error("too few parameters: " <> path_to_string(route.path))
      _, _ -> Ok(Nil)
    }
  })
}

pub fn segs_to_handler(
  segs: List(String),
  query_params: List(#(String, String)),
  routes: List(Route(a, b)),
) -> Result(a, Nil) {
  let route = segs_to_route(routes, segs)

  case route {
    Error(_) -> Error(Nil)
    Ok(route) -> {
      use search <- result.try(route.search.decode(query_params))

      case route.handler {
        Handler0(handler) -> Ok(handler(search))
        Handler1(handler) -> {
          let assert Ok(#(p1)) = get_params1(route, segs)
          Ok(handler(search, p1))
        }
        Handler2(handler) -> {
          let assert Ok(#(p1, p2)) = get_params2(route, segs)
          Ok(handler(search, p1, p2))
        }
      }
    }
  }
}

pub fn route_to_path(
  route: Route(a, b),
  search: b,
  params: List(String),
) -> String {
  let path =
    route.path
    |> list.map_fold(0, fn(acc, seg) {
      case seg {
        Literal(val) -> #(acc, val)
        Param(_) -> #(acc + 1, "$" <> int.to_string(acc))
      }
    })
    |> fn(arg) { arg.1 }
    |> string.join("/")

  let final_path =
    index_fold(params, path, fn(path, param, i) {
      string.replace(path, "$" <> int.to_string(i), param)
    })

  let query =
    search
    |> route.search.encode
    |> uri.query_to_string

  let query = case query {
    "" -> ""
    query -> "?" <> query
  }

  "/" <> final_path <> query
}

pub fn route_to_path0(route: Route(a, b), search: b) {
  route_to_path(route, search, [])
}

pub fn route_to_path1(route: Route(a, b), search: b, p1: String) {
  route_to_path(route, search, [p1])
}

pub fn route_to_path2(route: Route(a, b), search: b, p1: String, p2: String) {
  route_to_path(route, search, [p1, p2])
}

pub fn make_route0(
  path: String,
  search: SearchParams(b),
  handler: fn(b) -> a,
) -> Route(a, b) {
  let path = path_to_segments(path)
  Route(path, search, Handler0(handler))
}

pub fn make_route1(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String) -> a,
) -> Route(a, b) {
  let path = path_to_segments(path)
  Route(path, search, Handler1(handler))
}

pub fn make_route2(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String) -> a,
) -> Route(a, b) {
  let path = path_to_segments(path)
  Route(path, search, Handler2(handler))
}

pub fn segs_to_route(
  routes: List(Route(a, b)),
  segs: List(String),
) -> Result(Route(a, b), Nil) {
  let route_map =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(route.path)
      #(path_string, route)
    })
    |> dict.from_list

  let working_routes =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(route.path)
      #(path_string, route)
    })

  case do_segs_to_route(working_routes, segs) {
    Ok(#(path_string, _)) -> dict.get(route_map, path_string)
    Error(Nil) -> Error(Nil)
  }
}

pub fn path_to_segments(path: String) -> List(PathSegment) {
  path
  |> uri.path_segments()
  |> list.map(fn(seg) {
    case seg {
      "$" -> panic as { "missing parameter name for path " <> path }
      "$" <> param -> Param(param)
      val -> Literal(val)
    }
  })
}

pub fn get_params1(
  route: Route(a, b),
  segs: List(String),
) -> Result(#(String), Nil) {
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1)] -> Ok(#(p1))
    _ -> Error(Nil)
  }
}

pub fn get_params2(
  route: Route(a, b),
  segs: List(String),
) -> Result(#(String, String), Nil) {
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2)] -> Ok(#(p1, p2))
    _ -> Error(Nil)
  }
}

// --- --- --- PUBLIC TYPES --- --- ---

pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

pub type SearchParams(a) {
  SearchParams(
    decode: fn(List(#(String, String))) -> Result(a, Nil),
    encode: fn(a) -> List(#(String, String)),
  )
}

pub type Handler(a, b) {
  Handler0(fn(b) -> a)
  Handler1(fn(b, String) -> a)
  Handler2(fn(b, String, String) -> a)
}

pub type Route(a, b) {
  Route(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: Handler(a, b),
  )
}

// --- --- --- UTILITY FNS --- --- ---

fn param_seg_pair(route: Route(a, b), segs: List(String)) {
  route.path
  |> list.zip(segs)
  |> list.filter(fn(arg) {
    let #(path, _) = arg

    case path {
      Literal(_) -> False
      Param(_) -> True
    }
  })
}

fn do_segs_to_route(
  routes: List(#(String, Route(a, b))),
  segs: List(String),
) -> Result(#(String, Route(a, b)), Nil) {
  case segs {
    [] -> {
      routes
      |> list.find(fn(arg) { list.is_empty({ arg.1 }.path) })
    }
    [seg, ..rest] -> {
      let matching_routes =
        routes
        |> list.filter(fn(arg) { matches_first_segment(arg.1, seg) })
        |> list.sort(fn(a, b) { sort_by_first_segment(a.1, b.1) })
        |> list.map(fn(arg) { #(arg.0, advance_path(arg.1)) })

      case matching_routes {
        [] -> Error(Nil)
        [route] -> Ok(route)
        more -> do_segs_to_route(more, rest)
      }
    }
  }
}

fn path_to_string(path: List(PathSegment)) -> String {
  path
  |> list.map(fn(segment) {
    case segment {
      Literal(val) -> val
      Param(name) -> "$" <> name
    }
  })
  |> string.join("/")
  |> fn(path) { "/" <> path }()
}

fn advance_path(route: Route(a, b)) -> Route(a, b) {
  case route.path {
    [] -> route
    [_, ..path] -> {
      Route(..route, path:)
    }
  }
}

fn sort_by_first_segment(a: Route(a, b), b: Route(a, b)) -> order.Order {
  case list.first(a.path), list.first(b.path) {
    Ok(Literal(_)), Ok(Param(_)) -> order.Lt
    Ok(Param(_)), Ok(Param(_)) -> order.Eq
    Ok(_), Ok(Literal(_)) -> order.Gt
    Error(_), Ok(_) -> order.Lt
    Ok(_), Error(_) -> order.Gt
    Error(_), Error(_) -> order.Eq
  }
}

fn matches_first_segment(route: Route(a, b), seg: String) -> Bool {
  case list.first(route.path) {
    Error(_) -> False
    Ok(Literal(val)) -> val == seg
    Ok(Param(_)) -> True
  }
}

fn filter_params(path: List(PathSegment)) {
  list.filter(path, fn(seg) {
    case seg {
      Literal(_) -> False
      Param(_) -> True
    }
  })
}

fn index_fold(list, initial, fun) {
  list.index_map(list, fn(item, index) { #(item, index) })
  |> list.fold(initial, fn(acc, pair) {
    let #(item, index) = pair
    fun(acc, item, index)
  })
}
