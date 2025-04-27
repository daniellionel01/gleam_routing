import gleam/uri
import gleeunit/should
import routing/level_one

pub fn roundtrip_test() {
  level_one.route_to_path(level_one.Home)
  |> uri.path_segments()
  |> level_one.segs_to_route
  |> should.equal(Ok(level_one.Home))

  let profile = level_one.Profile("1")
  level_one.route_to_path(profile)
  |> uri.path_segments()
  |> level_one.segs_to_route
  |> should.equal(Ok(profile))
}
