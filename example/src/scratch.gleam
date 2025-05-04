import lustre/attribute
import lustre/element
import lustre/element/html
import wayfinder
import wisp

// --- --- --- DEFINE ROUTES --- --- ---

pub type SearchParams {
  Default(List(#(String, String)))
}

pub fn make_search_params() -> wayfinder.SearchParams(SearchParams) {
  wayfinder.SearchParams(
    decode: fn(params) { Ok(Default(params)) },
    encode: fn(params) {
      let Default(params) = params
      params
    },
  )
}

pub fn home_route() {
  wayfinder.make_route0("/", make_search_params(), fn(_) {
    html.div([], [html.text("home")])
  })
}

pub fn post_all_route() {
  wayfinder.make_route0("/post/all", make_search_params(), post_all_handler)
}

pub fn post_route() {
  wayfinder.make_route1("/post/$id", make_search_params(), fn(_, id: String) {
    html.div([], [html.text("post: " <> id)])
  })
}

pub fn routes() {
  [home_route(), post_all_route(), post_route()]
}

// --- --- --- VALIDATING ROUTE PATHS --- --- ---
pub fn main() {
  wayfinder.validate(routes())
  // ... rest of your code ...
}

// --- --- --- HANDLE WISP REQUESTS --- --- ---
pub fn handle_request(req: wisp.Request) {
  use req <- middleware(req)

  let segs = wisp.path_segments(req)
  let query = wisp.get_query(req)
  let response = wayfinder.segs_to_handler(segs, query, routes())

  case response {
    Error(_) -> wisp.not_found()
    Ok(response) ->
      response
      |> element.to_document_string_tree
      |> wisp.html_response(200)
  }
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}

// --- --- --- LINK PAGE IN HTML --- --- ---
pub fn post_all_handler(_params: SearchParams) {
  html.div([], [
    html.a(
      [
        attribute.href(wayfinder.route_to_path1(
          post_route(),
          Default([]),
          "two",
        )),
      ],
      [html.text("post 1")],
    ),
  ])
}
