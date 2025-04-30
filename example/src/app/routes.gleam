import lustre/element/html
import wayfinder.{Literal, Param, Route0, Route1, Wrapper0, Wrapper1}

pub fn home_handler() {
  html.div([], [])
}

pub fn post_all_handler() {
  html.div([], [])
}

pub fn post_handler(_id: String) {
  html.div([], [])
}

pub const home_route = Route0("home", [], home_handler)

pub const post_all_route = Route0(
  "post_all",
  [Literal("post"), Literal("all")],
  post_all_handler,
)

pub const post_route = Route1(
  "post_details",
  [Literal("post"), Param("id")],
  post_handler,
)

pub const routes = [
  Wrapper0(home_route),
  Wrapper0(post_all_route),
  Wrapper1(post_route),
]
