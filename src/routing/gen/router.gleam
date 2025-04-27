import routing/level_three

pub type Route {
  Home()
  Profile(id: String)
}

pub fn segs_to_route(route: Route) -> String {
  case route {
    [] -> Ok(Home)
    ["profile", id] -> Ok(Profile)
    _ -> Error(Nil)
  }
}

pub fn route_to_html(route: Route) -> String {
  case route {
    Home() -> level_three.home()
    Profile(id) -> level_three.profile(id)
  }
}

pub fn route_to_path(route: Route) -> String {
  case route {
    Home() -> "/"
    Profile(id) -> "/" <> "profile/" <> id
  }
}