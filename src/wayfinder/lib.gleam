import gleam/int
import gleam/list
import gleam/string
import gleam/uri
import lustre/element

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

pub fn segs_to_route(routes: List(RouteWrapper), segs: List(String)) {
  todo
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

pub type RouteWrapper {
  RouteWrapper0(Route0)
  RouteWrapper1(Route1)
  RouteWrapper2(Route2)
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
