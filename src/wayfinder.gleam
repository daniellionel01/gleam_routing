import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/string
import gleam/uri

pub fn validate(routes: List(Wrapper(a, b))) -> Nil {
  case do_validate(routes) {
    Error(msg) -> panic as msg
    Ok(_) -> Nil
  }
}

pub fn do_validate(routes: List(Wrapper(a, b))) -> Result(Nil, String) {
  routes
  |> list.try_each(fn(route) {
    case route {
      Wrapper0(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, ..] -> {
            Error("too many parameters: " <> path_to_string(route.path))
          }
          [] -> Ok(Nil)
        }
      }
      Wrapper1(route) -> {
        let params = filter_params(route.path)
        case params {
          [_] -> Ok(Nil)
          [_, ..] ->
            Error("too many parameters: " <> path_to_string(route.path))
          [] -> Error("too few parameters: " <> path_to_string(route.path))
        }
      }
      Wrapper2(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, _] -> Ok(Nil)
          [_, _, _, ..] ->
            Error("too many parameters: " <> path_to_string(route.path))
          _ -> Error("too few parameters: " <> path_to_string(route.path))
        }
      }
      Wrapper3(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, _, _] -> Ok(Nil)
          [_, _, _, _, ..] ->
            Error("too many parameters: " <> path_to_string(route.path))
          _ -> Error("too few parameters: " <> path_to_string(route.path))
        }
      }
      Wrapper4(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, _, _, _] -> Ok(Nil)
          [_, _, _, _, _, ..] ->
            Error("too many parameters: " <> path_to_string(route.path))
          _ -> Error("too few parameters: " <> path_to_string(route.path))
        }
      }
      Wrapper5(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, _, _, _, _] -> Ok(Nil)
          [_, _, _, _, _, _, ..] ->
            Error("too many parameters: " <> path_to_string(route.path))
          _ -> Error("too few parameters: " <> path_to_string(route.path))
        }
      }
    }
  })
}

pub fn segs_to_handler(
  segs: List(String),
  query: String,
  routes: List(Wrapper(a, b)),
) -> Result(a, Nil) {
  let route = segs_to_route(routes, segs)
  let query_params = case uri.parse_query(query) {
    Ok(params) -> params
    Error(_) -> []
  }

  case route {
    Error(_) -> Error(Nil)
    Ok(route) -> {
      case route {
        Wrapper0(route) -> {
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params))
          }
        }
        Wrapper1(route) -> {
          let assert Ok(#(p1)) = get_params1(route, segs)
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params, p1))
          }
        }
        Wrapper2(route) -> {
          let assert Ok(#(p1, p2)) = get_params2(route, segs)
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params, p1, p2))
          }
        }
        Wrapper3(route) -> {
          let assert Ok(#(p1, p2, p3)) = get_params3(route, segs)
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params, p1, p2, p3))
          }
        }
        Wrapper4(route) -> {
          let assert Ok(#(p1, p2, p3, p4)) = get_params4(route, segs)
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params, p1, p2, p3, p4))
          }
        }
        Wrapper5(route) -> {
          let assert Ok(#(p1, p2, p3, p4, p5)) = get_params5(route, segs)
          case route.search.decode(query_params) {
            Error(_) -> Error(Nil)
            Ok(params) -> Ok(route.handler(params, p1, p2, p3, p4, p5))
          }
        }
      }
    }
  }
}

pub fn route_to_path0(route: Route0(a, b), params: b) {
  let path =
    route.path
    |> list.map(fn(seg) {
      case seg {
        Literal(val) -> val
        Param(_) -> ""
      }
    })
    |> string.join("/")

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn route_to_path1(route: Route1(a, b), p1: String, params: b) {
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
    |> string.replace("$0", p1)

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn route_to_path2(route: Route2(a, b), p1: String, p2: String, params: b) {
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
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn route_to_path3(
  route: Route3(a, b),
  p1: String,
  p2: String,
  p3: String,
  params: b,
) {
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
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)
    |> string.replace("$2", p3)

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn route_to_path4(
  route: Route4(a, b),
  p1: String,
  p2: String,
  p3: String,
  p4: String,
  params: b,
) {
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
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)
    |> string.replace("$2", p3)
    |> string.replace("$3", p4)

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn route_to_path5(
  route: Route5(a, b),
  p1: String,
  p2: String,
  p3: String,
  p4: String,
  p5: String,
  params: b,
) {
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
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)
    |> string.replace("$2", p3)
    |> string.replace("$3", p4)
    |> string.replace("$4", p5)

  let query =
    params
    |> route.search.encode
    |> uri.query_to_string

  "/" <> path <> "/" <> query
}

pub fn make_route0(
  path: String,
  search: SearchParams(b),
  handler: fn(b) -> a,
) -> Route0(a, b) {
  Route0(path_to_segments(path), search, handler)
}

pub fn make_route1(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String) -> a,
) -> Route1(a, b) {
  Route1(path_to_segments(path), search, handler)
}

pub fn make_route2(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String) -> a,
) -> Route2(a, b) {
  Route2(path_to_segments(path), search, handler)
}

pub fn make_route3(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String) -> a,
) -> Route3(a, b) {
  Route3(path_to_segments(path), search, handler)
}

pub fn make_route4(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String, String) -> a,
) -> Route4(a, b) {
  Route4(path_to_segments(path), search, handler)
}

pub fn make_route5(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String, String, String) -> a,
) -> Route5(a, b) {
  Route5(path_to_segments(path), search, handler)
}

pub fn make_wrap0(
  path: String,
  search: SearchParams(b),
  handler: fn(b) -> a,
) -> Wrapper(a, b) {
  Wrapper0(make_route0(path, search, handler))
}

pub fn make_wrap1(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String) -> a,
) -> Wrapper(a, b) {
  Wrapper1(make_route1(path, search, handler))
}

pub fn make_wrap2(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String) -> a,
) -> Wrapper(a, b) {
  Wrapper2(make_route2(path, search, handler))
}

pub fn make_wrap3(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String) -> a,
) -> Wrapper(a, b) {
  Wrapper3(make_route3(path, search, handler))
}

pub fn make_wrap4(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String, String) -> a,
) -> Wrapper(a, b) {
  Wrapper4(make_route4(path, search, handler))
}

pub fn make_wrap5(
  path: String,
  search: SearchParams(b),
  handler: fn(b, String, String, String, String, String) -> a,
) -> Wrapper(a, b) {
  Wrapper5(make_route5(path, search, handler))
}

pub fn segs_to_route(
  routes: List(Wrapper(a, b)),
  segs: List(String),
) -> Result(Wrapper(a, b), Nil) {
  // Since we're modifying the path inside of the routes list,
  // we're going to store it as a tuple that converts the path segments
  // into a unique path id (f.e. "/post/$id")
  // Then after we've found a matching route (which is going to have an empty path)
  // we can turn it back into the original route by matching the unique path id

  let route_map =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(wrapper_path(route))
      #(path_string, route)
    })
    |> dict.from_list

  let working_routes =
    routes
    |> list.map(fn(route) {
      let path_string = path_to_string(wrapper_path(route))
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
  route: Route1(a, b),
  segs: List(String),
) -> Result(#(String), Nil) {
  let route = Wrapper1(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1)] -> Ok(#(p1))
    _ -> Error(Nil)
  }
}

pub fn get_params2(
  route: Route2(a, b),
  segs: List(String),
) -> Result(#(String, String), Nil) {
  let route = Wrapper2(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2)] -> Ok(#(p1, p2))
    _ -> Error(Nil)
  }
}

pub fn get_params3(
  route: Route3(a, b),
  segs: List(String),
) -> Result(#(String, String, String), Nil) {
  let route = Wrapper3(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2), #(_, p3)] -> Ok(#(p1, p2, p3))
    _ -> Error(Nil)
  }
}

pub fn get_params4(
  route: Route4(a, b),
  segs: List(String),
) -> Result(#(String, String, String, String), Nil) {
  let route = Wrapper4(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2), #(_, p3), #(_, p4)] -> Ok(#(p1, p2, p3, p4))
    _ -> Error(Nil)
  }
}

pub fn get_params5(
  route: Route5(a, b),
  segs: List(String),
) -> Result(#(String, String, String, String, String), Nil) {
  let route = Wrapper5(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2), #(_, p3), #(_, p4), #(_, p5)] ->
      Ok(#(p1, p2, p3, p4, p5))
    _ -> Error(Nil)
  }
}

// --- --- --- PUBLIC TYPES --- --- ---

pub type Wrapper(a, b) {
  Wrapper0(Route0(a, b))
  Wrapper1(Route1(a, b))
  Wrapper2(Route2(a, b))
  Wrapper3(Route3(a, b))
  Wrapper4(Route4(a, b))
  Wrapper5(Route5(a, b))
}

pub type SearchParams(a) {
  SearchParams(
    decode: fn(List(#(String, String))) -> Result(a, Nil),
    encode: fn(a) -> List(#(String, String)),
  )
}

pub type Route0(a, b) {
  Route0(path: List(PathSegment), search: SearchParams(b), handler: fn(b) -> a)
}

pub type Route1(a, b) {
  Route1(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: fn(b, String) -> a,
  )
}

pub type Route2(a, b) {
  Route2(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: fn(b, String, String) -> a,
  )
}

pub type Route3(a, b) {
  Route3(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: fn(b, String, String, String) -> a,
  )
}

pub type Route4(a, b) {
  Route4(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: fn(b, String, String, String, String) -> a,
  )
}

pub type Route5(a, b) {
  Route5(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: fn(b, String, String, String, String, String) -> a,
  )
}

pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

// --- --- --- UTILITY FNS --- --- ---

fn param_seg_pair(route: Wrapper(a, b), segs: List(String)) {
  wrapper_path(route)
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
  routes: List(#(String, Wrapper(a, b))),
  segs: List(String),
) -> Result(#(String, Wrapper(a, b)), Nil) {
  case segs {
    [] -> {
      routes
      |> list.find(fn(arg) { list.is_empty(wrapper_path(arg.1)) })
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

fn wrapper_path(wrapper: Wrapper(a, b)) {
  case wrapper {
    Wrapper0(route) -> route.path
    Wrapper1(route) -> route.path
    Wrapper2(route) -> route.path
    Wrapper3(route) -> route.path
    Wrapper4(route) -> route.path
    Wrapper5(route) -> route.path
  }
}

fn advance_path(wrapper: Wrapper(a, b)) -> Wrapper(a, b) {
  case wrapper_path(wrapper) {
    [] -> wrapper
    [_, ..path] -> {
      case wrapper {
        Wrapper0(route) -> Wrapper0(Route0(..route, path: path))
        Wrapper1(route) -> Wrapper1(Route1(..route, path: path))
        Wrapper2(route) -> Wrapper2(Route2(..route, path: path))
        Wrapper3(route) -> Wrapper3(Route3(..route, path: path))
        Wrapper4(route) -> Wrapper4(Route4(..route, path: path))
        Wrapper5(route) -> Wrapper5(Route5(..route, path: path))
      }
    }
  }
}

fn sort_by_first_segment(a: Wrapper(a, b), b: Wrapper(a, b)) -> order.Order {
  case list.first(wrapper_path(a)), list.first(wrapper_path(b)) {
    Ok(Literal(_)), Ok(Param(_)) -> order.Lt
    Ok(Param(_)), Ok(Param(_)) -> order.Eq
    Ok(_), Ok(Literal(_)) -> order.Gt
    Error(_), Ok(_) -> order.Lt
    Ok(_), Error(_) -> order.Gt
    Error(_), Error(_) -> order.Eq
  }
}

fn matches_first_segment(wrapper: Wrapper(a, b), seg: String) -> Bool {
  case list.first(wrapper_path(wrapper)) {
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
