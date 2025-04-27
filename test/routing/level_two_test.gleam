import gleam/list
import gleam/uri
import gleeunit/should
import routing/level_two

pub const test_routes: List(level_two.Route) = [
  level_two.Home,
  level_two.Profile("1"),
  level_two.Campaigns(level_two.CampaignsSearch(3, 5)),
]

pub fn roundtrip_test() {
  list.each(test_routes, fn(route) {
    level_two.route_to_path(route)
    |> uri.path_segments()
    |> level_two.segs_to_route
    |> should.equal(Ok(route))
  })
}
