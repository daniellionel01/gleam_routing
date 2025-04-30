import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/set
import gleam/string
import gleam/uri
import lustre/element

pub type Error {
  MissingParameter
  TooManyParameters
  DuplicatePath
}

fn filter_params(path: List(PathSegment)) {
  list.filter(path, fn(seg) {
    case seg {
      Literal(_) -> False
      Param(_) -> True
    }
  })
}

pub fn validate(routes: List(Wrapper)) -> List(Error) {
  routes
  |> list.map(fn(route) {
    case route {
      Wrapper0(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, ..] -> option.Some(TooManyParameters)
          [] -> option.None
        }
      }
      Wrapper1(route) -> {
        let params = filter_params(route.path)
        case params {
          [_] -> option.None
          [_, ..] -> option.Some(TooManyParameters)
          [] -> option.Some(MissingParameter)
        }
      }
      Wrapper2(route) -> {
        let params = filter_params(route.path)
        case params {
          [_, _] -> option.None
          [_, _, _, ..] -> option.Some(TooManyParameters)
          _ -> option.Some(MissingParameter)
        }
      }
    }
  })
  |> list.filter_map(fn(err) {
    case err {
      option.None -> Error(Nil)
      option.Some(err) -> Ok(err)
    }
  })
}

pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

pub fn route_to_path0(route: Route0) {
  let path =
    route.path
    |> list.map(fn(seg) {
      case seg {
        Literal(val) -> val
        Param(_) -> ""
      }
    })
    |> string.join("/")

  "/" <> path
}

pub fn route_to_path1(route: Route1, p1: String) {
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

  "/" <> path
}

pub fn route_to_path2(route: Route2, p1: String, p2: String) {
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

  "/" <> path
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

fn wrapper_path(wrapper: Wrapper) {
  case wrapper {
    Wrapper0(route) -> route.path
    Wrapper1(route) -> route.path
    Wrapper2(route) -> route.path
  }
}

fn advance_path(wrapper: Wrapper) -> Wrapper {
  case wrapper_path(wrapper) {
    [] -> wrapper
    [_, ..path] -> {
      case wrapper {
        Wrapper0(route) -> Wrapper0(Route0(..route, path: path))
        Wrapper1(route) -> Wrapper1(Route1(..route, path: path))
        Wrapper2(route) -> Wrapper2(Route2(..route, path: path))
      }
    }
  }
}

fn sort_by_first_segment(a: Wrapper, b: Wrapper) -> order.Order {
  case list.first(wrapper_path(a)), list.first(wrapper_path(b)) {
    Ok(Literal(_)), Ok(Param(_)) -> order.Lt
    Ok(Param(_)), Ok(Param(_)) -> order.Eq
    Ok(_), Ok(Literal(_)) -> order.Gt
    Error(_), Ok(_) -> order.Lt
    Ok(_), Error(_) -> order.Gt
    Error(_), Error(_) -> order.Eq
  }
}

fn matches_first_segment(wrapper: Wrapper, seg: String) -> Bool {
  case list.first(wrapper_path(wrapper)) {
    Error(_) -> False
    Ok(Literal(val)) -> val == seg
    Ok(Param(_)) -> True
  }
}

pub fn segs_to_route(
  routes: List(Wrapper),
  segs: List(String),
) -> Result(Wrapper, Nil) {
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

fn do_segs_to_route(
  routes: List(#(String, Wrapper)),
  segs: List(String),
) -> Result(#(String, Wrapper), Nil) {
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

fn param_seg_pair(route: Wrapper, segs: List(String)) {
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

pub fn get_params1(route: Route1, segs: List(String)) -> Result(#(String), Nil) {
  let route = Wrapper1(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1)] -> Ok(#(p1))
    _ -> Error(Nil)
  }
}

pub fn get_params2(
  route: Route2,
  segs: List(String),
) -> Result(#(String, String), Nil) {
  let route = Wrapper2(route)
  let combined = param_seg_pair(route, segs)
  case combined {
    [#(_, p1), #(_, p2)] -> Ok(#(p1, p2))
    _ -> Error(Nil)
  }
}

pub type Wrapper {
  Wrapper0(Route0)
  Wrapper1(Route1)
  Wrapper2(Route2)
}

pub type Route0 {
  Route0(path: List(PathSegment), handler: fn() -> element.Element(Nil))
}

pub type Route1 {
  Route1(path: List(PathSegment), handler: fn(String) -> element.Element(Nil))
}

pub type Route2 {
  Route2(
    path: List(PathSegment),
    handler: fn(String, String) -> element.Element(Nil),
  )
}
