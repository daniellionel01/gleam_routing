import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import gleam/uri

// --- --- --- PUBLIC TYPES --- --- ---

pub type Route(handler) {
  Route(path: List(PathSegment), handler: handler)
}

pub type Handler0(a) =
  fn() -> a

pub type Handler1(a) =
  fn(String) -> a

pub type Handler2(a) =
  fn(String, String) -> a

pub type Handler3(a) =
  fn(String, String, String) -> a

pub type Router(a) {
  Router0(Route(Handler0(a)))
  Router1(Route(Handler1(a)))
  Router2(Route(Handler2(a)))
  Router3(Route(Handler3(a)))
}

pub type Error {
  MissingParameter
  TooManyParameters
  DuplicatePath
}

pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

// --- --- --- PUBLIC FUNCTIONS --- --- ---

pub fn validate(routes: List(Router(a))) -> List(Error) {
  routes
  |> list.filter_map(fn(router) {
    let expected_param_count = case router {
      Router0(_) -> 0
      Router1(_) -> 1
      Router2(_) -> 2
      Router3(_) -> 3
    }

    let params = filter_params(get_path(router))
    let actual_count = list.length(params)

    case
      actual_count > expected_param_count,
      actual_count < expected_param_count
    {
      True, _ -> Ok(TooManyParameters)
      _, True -> Ok(MissingParameter)
      _, _ -> Error(Nil)
    }
  })
}

pub fn route_to_path(router: Router(a), params: List(String)) -> String {
  let path = get_path(router)

  let path_with_placeholders =
    path
    |> list.map_fold(0, fn(acc, seg) {
      case seg {
        Literal(val) -> #(acc, val)
        Param(_) -> #(acc + 1, "$" <> int.to_string(acc))
      }
    })
    |> fn(arg) { arg.1 }
    |> string.join("/")

  // Replace placeholders with actual parameters
  let final_path =
    index_fold(params, path_with_placeholders, fn(path, param, i) {
      string.replace(path, "$" <> int.to_string(i), param)
    })

  "/" <> final_path
}

pub fn route_to_path0(route: Route(Handler0(a))) -> String {
  route_to_path(Router0(route), [])
}

pub fn route_to_path1(route: Route(Handler1(a)), p1: String) -> String {
  route_to_path(Router1(route), [p1])
}

pub fn route_to_path2(
  route: Route(Handler2(a)),
  p1: String,
  p2: String,
) -> String {
  route_to_path(Router2(route), [p1, p2])
}

pub fn route_to_path3(
  route: Route(Handler3(a)),
  p1: String,
  p2: String,
  p3: String,
) -> String {
  route_to_path(Router3(route), [p1, p2, p3])
}

pub fn segs_to_route(
  routes: List(Router(a)),
  segs: List(String),
) -> Result(Router(a), Nil) {
  // Since we're modifying the path inside of the routes list,
  // we're going to store it as a tuple that converts the path segments
  // into a unique path id (f.e. "/post/$id")
  // Then after we've found a matching route (which is going to have an empty path)
  // we can turn it back into the original route by matching the unique path id

  let route_map =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(get_path(route))
      #(path_string, route)
    })
    |> dict.from_list

  let working_routes =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(get_path(route))
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
  route: Route(Handler1(a)),
  segs: List(String),
) -> Result(#(String), Nil) {
  let router = Router1(route)
  let combined = param_seg_pair(router, segs)
  case combined {
    [#(_, p1)] -> Ok(#(p1))
    _ -> Error(Nil)
  }
}

pub fn get_params2(
  route: Route(Handler2(a)),
  segs: List(String),
) -> Result(#(String, String), Nil) {
  let router = Router2(route)
  let combined = param_seg_pair(router, segs)
  case combined {
    [#(_, p1), #(_, p2)] -> Ok(#(p1, p2))
    _ -> Error(Nil)
  }
}

pub fn get_params3(
  route: Route(Handler3(a)),
  segs: List(String),
) -> Result(#(String, String, String), Nil) {
  let router = Router3(route)
  let combined = param_seg_pair(router, segs)
  case combined {
    [#(_, p1), #(_, p2), #(_, p3)] -> Ok(#(p1, p2, p3))
    _ -> Error(Nil)
  }
}

// --- --- --- UTILITY FNS --- --- ---

fn get_path(router: Router(a)) -> List(PathSegment) {
  case router {
    Router0(route) -> route.path
    Router1(route) -> route.path
    Router2(route) -> route.path
    Router3(route) -> route.path
  }
}

fn param_seg_pair(
  router: Router(a),
  segs: List(String),
) -> List(#(PathSegment, String)) {
  get_path(router)
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
  routes: List(#(String, Router(a))),
  segs: List(String),
) -> Result(#(String, Router(a)), Nil) {
  case segs {
    [] -> {
      routes
      |> list.find(fn(arg) { list.is_empty(get_path(arg.1)) })
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

fn advance_path(router: Router(a)) -> Router(a) {
  case get_path(router) {
    [] -> router
    [_, ..path] -> {
      case router {
        Router0(route) -> Router0(Route(..route, path: path))
        Router1(route) -> Router1(Route(..route, path: path))
        Router2(route) -> Router2(Route(..route, path: path))
        Router3(route) -> Router3(Route(..route, path: path))
      }
    }
  }
}

fn sort_by_first_segment(a: Router(a), b: Router(a)) -> order.Order {
  case list.first(get_path(a)), list.first(get_path(b)) {
    Ok(Literal(_)), Ok(Param(_)) -> order.Lt
    Ok(Param(_)), Ok(Param(_)) -> order.Eq
    Ok(_), Ok(Literal(_)) -> order.Gt
    Error(_), Ok(_) -> order.Lt
    Ok(_), Error(_) -> order.Gt
    Error(_), Error(_) -> order.Eq
  }
}

fn matches_first_segment(router: Router(a), seg: String) -> Bool {
  case list.first(get_path(router)) {
    Error(_) -> False
    Ok(Literal(val)) -> val == seg
    Ok(Param(_)) -> True
  }
}

fn filter_params(path: List(PathSegment)) -> List(PathSegment) {
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
