import wayfinder

pub type Route {
  Home(path: String, handler: fn(wayfinder.SearchParams) -> String)
  Post(path: String, handler: fn(wayfinder.SearchParams, String) -> String)
}

pub const home_route = Home("/", home_handler)

pub const post_route = Post("/post/$postId", post_handler)

pub fn home_handler(_params: wayfinder.SearchParams) {
  "<div>home</div>"
}

pub fn post_handler(_params: wayfinder.SearchParams, post_id: String) {
  "<div>post: " <> post_id <> "</div>"
}

// === === === CODE BELOW IS AUTO GENERATED === === ===

pub fn uri_to_handler(
  segs: List(String),
  query: List(#(String, String)),
) -> Result(String, Nil) {
  case segs {
    [] -> Ok(home_handler(query))
    ["post", post_id] -> Ok(post_handler(query, post_id))
    _ -> Error(Nil)
  }
}

pub fn home_path() {
  "/" <> ""
}

pub fn post_path(post_id) {
  "/" <> "post" <> "/" <> post_id
}
