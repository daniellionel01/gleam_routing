import gleam/uri
import gleeunit/should
import routing/level_two

pub fn roundtrip_test() {
  level_two.route_to_path(level_two.Home)
  |> uri.path_segments()
  |> level_two.segs_to_route
  |> should.equal(Ok(level_two.Home))

  let profile = level_two.Profile("1")
  level_two.route_to_path(profile)
  |> uri.path_segments()
  |> level_two.segs_to_route
  |> should.equal(Ok(profile))

  let campaigns = level_two.Campaigns(level_two.CampaignsSearch(3, 5))
  level_two.route_to_path(campaigns)
  |> uri.path_segments()
  |> level_two.segs_to_route
  |> should.equal(Ok(campaigns))
}
