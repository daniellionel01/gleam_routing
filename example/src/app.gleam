import app/routes
import wayfinder

pub fn main() -> Nil {
  // wayfinder.validate(routes.routes)

  wayfinder.route_to_path0(routes.home_route)
  |> echo

  wayfinder.route_to_path1(routes.post_route, "1")
  |> echo

  let _ =
    wayfinder.segs_to_route(routes.routes, [])
    |> echo

  let _ =
    wayfinder.segs_to_route(routes.routes, ["post", "2"])
    |> echo

  let _ =
    wayfinder.segs_to_route(routes.routes, ["post", "all"])
    |> echo

  Nil
}
