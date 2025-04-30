import gleam/int
import gleam/list
import gleam/order
import gleam/string
import gleam/uri
import lustre/element

pub fn validate(routes: List(Wrapper)) {
  routes
  |> list.each(fn(route) {
    todo
    // todo
  })
  // TODO find invalid paths -> too few parameters
  // TODO find invalid paths -> missing parameter name
  // TODO validate unique route names
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
    |> list.map(fn(seg) {
      case seg {
        Literal(val) -> val
        Param(_) -> "$0"
      }
    })
    |> string.join("/")
    |> string.replace("$0", p1)

  "/" <> path
}

pub fn route_to_path2(route: Route2, p1: String, p2: String) {
  let path =
    route.path
    |> list.index_map(fn(seg, index) {
      case seg {
        Literal(val) -> val
        Param(_) -> "$" <> int.to_string(index)
      }
    })
    |> string.join("/")
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)

  "/" <> path
}

pub fn route_to_path3(route: Route3, p1: String, p2: String, p3: String) {
  let path =
    route.path
    |> list.index_map(fn(seg, index) {
      case seg {
        Literal(val) -> val
        Param(_) -> "$" <> int.to_string(index)
      }
    })
    |> string.join("/")
    |> string.replace("$0", p1)
    |> string.replace("$1", p2)
    |> string.replace("$2", p3)

  "/" <> path
}

pub fn wrapper_path(wrapper: Wrapper) {
  case wrapper {
    Wrapper0(route) -> route.path
    Wrapper1(route) -> route.path
    Wrapper2(route) -> route.path
  }
}

pub fn segs_to_route(
  routes: List(Wrapper),
  segs: List(String),
) -> Result(Wrapper, Nil) {
  case segs {
    [] -> {
      list.find(routes, fn(route) {
        let path = wrapper_path(route)
        case path {
          [] -> True
          _ -> False
        }
      })
    }
    [seg, ..rest] -> {
      let matching_routes =
        routes
        |> list.filter(fn(wrapper) {
          case list.first(wrapper_path(wrapper)) {
            Error(_) -> False
            Ok(path_seg) -> {
              case path_seg {
                Literal(val) -> val == seg
                Param(_) -> True
              }
            }
          }
        })
        |> list.sort(fn(a, b) {
          let x = list.first(wrapper_path(a))
          let y = list.first(wrapper_path(b))
          case x, y {
            Ok(x), Ok(y) -> {
              case x, y {
                Literal(_), Param(_) -> order.Lt
                Param(_), Param(_) -> order.Eq
                _, Literal(_) -> order.Gt
              }
            }
            Error(_), Ok(_) -> order.Lt
            Ok(_), Error(_) -> order.Gt
            Error(_), Error(_) -> order.Eq
          }
        })
        |> list.map(fn(wrapper) {
          let assert [_, ..path] = wrapper_path(wrapper)
          case wrapper {
            Wrapper0(route) -> Wrapper0(Route0(..route, path:))
            Wrapper1(route) -> Wrapper1(Route1(..route, path:))
            Wrapper2(route) -> Wrapper2(Route2(..route, path:))
          }
        })
      case matching_routes {
        [] -> Error(Nil)
        [route] -> Ok(route)
        more -> {
          segs_to_route(more, rest)
        }
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

pub type Wrapper {
  Wrapper0(Route0)
  Wrapper1(Route1)
  Wrapper2(Route2)
}

pub type Route0 {
  Route0(
    name: String,
    path: List(PathSegment),
    handler: fn() -> element.Element(Nil),
  )
}

pub type Route1 {
  Route1(
    name: String,
    path: List(PathSegment),
    handler: fn(String) -> element.Element(Nil),
  )
}

pub type Route2 {
  Route2(
    name: String,
    path: List(PathSegment),
    handler: fn(String, String) -> element.Element(Nil),
  )
}

pub type Route3 {
  Route3(
    name: String,
    path: List(PathSegment),
    handler: fn(String, String, String) -> element.Element(Nil),
  )
}
