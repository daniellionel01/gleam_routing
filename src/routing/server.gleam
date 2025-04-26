import gleam/erlang/process
import gleam/io
import lustre/attribute as attr
import lustre/element.{type Element}
import lustre/element/html
import mist
import wisp
import wisp/wisp_mist

pub type Handler(a) =
  fn(List(String)) -> Element(a)

pub fn serve(seg_to_el: Handler(a)) {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let handler = fn(req) {
    use _req <- middleware(req)
    let segs = wisp.path_segments(req)
    let el = seg_to_el(segs)
    serve_html(el)
  }
  io.println("Starting web server on port 8000...")
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn serve_html(el: element.Element(a)) -> wisp.Response {
  [el]
  |> root_layout()
  |> element.to_document_string_tree
  |> wisp.html_response(200)
}

fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handle_request(req)
}

const style = "
  body {
    font-family: Arial, sans-serif;
    margin: 30px;
  }
"

fn root_layout(elements: List(Element(t))) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Glue"),
      html.meta([
        attr.name("viewport"),
        attr.content("width=device-width, initial-scale=1"),
      ]),
      html.style([attr.rel("stylesheet")], style),
    ]),
    html.body([], elements),
  ])
}
