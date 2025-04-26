pub type Route {
  Home
  Profile(id: String)
}

pub fn route_to_path(route: Route) {
  case route {
    Home -> "/"
    Profile(id) -> "/profile/" <> id
  }
}

pub fn segs_to_route(segs: List(String)) -> Result(Route, Nil) {
  case segs {
    [] -> Ok(Home)
    ["profile", id] -> Ok(Profile(id))
    _ -> Error(Nil)
  }
}

pub fn route_to_html(route: Route) -> String {
  case route {
    Home -> home()
    Profile(id) -> profile(id)
  }
}

pub fn handler(segs: List(String)) -> String {
  case segs_to_route(segs) {
    Ok(route) -> {
      route_to_html(route)
    }
    Error(_) -> "404"
  }
}

pub fn home() -> String {
  "
  <div>
    <div>Home</div>
    <a href=\"" <> route_to_path(Profile("me")) <> "\">Profile</a>
  </div>
  "
}

pub fn profile(id: String) -> String {
  "
  <div>
    <div>Profile: " <> id <> "</div>
    <a href=\"" <> route_to_path(Home) <> "\">Home</a>
  </div>
  "
}
