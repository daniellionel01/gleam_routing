import wayfinder

pub type Route {
  Home(path: String, handler: fn(wayfinder.SearchParams) -> String)
  Post(path: String, handler: fn(wayfinder.SearchParams, String) -> String)
}

pub const home_route = Home("/", home_handler)

pub const post_route = Home("/post/$postId", home_handler)

pub fn home_handler(_params: wayfinder.SearchParams) {
  "<div>home</div>"
}

pub fn post_handler(_params: wayfinder.SearchParams, post_id: String) {
  "<div>post: " <> post_id <> "</div>"
}
