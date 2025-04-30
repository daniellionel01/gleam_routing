import gleam/erlang/process
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wayfinder.{Wrapper0, Wrapper1}
import wisp
import wisp/wisp_mist

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

fn serve_html(el: element.Element(a)) -> wisp.Response {
  el
  |> element.to_document_string_tree
  |> wisp.html_response(200)
}

fn handle_request(req: wisp.Request) {
  use req <- middleware(req)

  let segs = wisp.path_segments(req)
  let response = wayfinder.segs_to_handler(segs, routes())

  case response {
    Error(_) -> wisp.not_found()
    Ok(response) -> serve_html(response)
  }
}

pub fn main() -> Nil {
  wayfinder.validate(routes())

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(handle_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

pub fn home_route() {
  wayfinder.make_route0("/", fn() { html.div([], [html.text("home")]) })
}

pub fn post_all_route() {
  wayfinder.make_route0("/post/all", post_all_handler)
}

pub fn post_route() {
  wayfinder.make_route1("/post/$id", fn(id: String) {
    html.div([], [html.text("post: " <> id)])
  })
}

pub fn routes() {
  [Wrapper0(home_route()), Wrapper0(post_all_route()), Wrapper1(post_route())]
}

pub fn post_all_handler() {
  html.div([], [
    html.a([attribute.href(wayfinder.route_to_path1(post_route(), "two"))], [
      html.text("post 1"),
    ]),
  ])
}
