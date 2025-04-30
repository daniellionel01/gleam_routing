import lustre/element/html
import wayfinder
import wayfinder/lib.{Route0, Route1}

pub fn home_handler() {
  html.div([], [])
}

pub fn post_handler(_id: String) {
  html.div([], [])
}

pub const home = Route0("home", "/", home_handler)

pub const post = Route1("post", "/post/$id", post_handler)

pub fn main() {
  wayfinder.generate(
    [
      wayfinder.Route("home", "/", "app/handler", "handler.home"),
      wayfinder.Route(
        "profile",
        "/profile/$id",
        "app/handler",
        "handler.profile",
      ),
    ],
    "./src/app/router.gleam",
  )
}
