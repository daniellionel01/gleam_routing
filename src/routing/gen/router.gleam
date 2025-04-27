import routing/level_three

pub type Route {
  Home()
  Profile(id: String)
}

pub fn route_to_html(route: Route) -> String {
  case route {
    Home() -> level_three.home()
    Profile(id) -> level_three.profile(id)
  }
}