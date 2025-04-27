pub type Route(a) {
  Route(path: String, handler: a)
}

pub const home_route = Route("/", home)

pub const profile_route = Route("/profile/$id", profile)

pub fn home() -> String {
  todo as "home page html"
}

pub fn profile(id: String) -> String {
  todo as "profile page html"
}
