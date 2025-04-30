import lustre/element/html
import wayfinder
import wayfinder/lib

pub fn home_handler() {
  html.div([], [])
}

pub fn post_handler(_id: String) {
  html.div([], [])
}

pub fn main() {
  wayfinder.generate([
    lib.Route0("home", lib.path_to_segments("/"), home_handler),
    lib.Route1("post", lib.path_to_segments("/post/$id"), post_handler),
  ])
}
