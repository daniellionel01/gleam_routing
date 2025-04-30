import gleam/erlang/process
import gleam/result
import lustre/element
import lustre/element/html
import mist
import wayfinder.{Literal, Param, Route0, Route1, Wrapper0, Wrapper1, Wrapper2}
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
  let route = wayfinder.segs_to_route(routes, segs)
  case route {
    Error(_) -> wisp.not_found()
    Ok(route) -> {
      case route {
        Wrapper0(route) -> {
          route.handler()
          |> serve_html
        }
        Wrapper1(route) -> {
          let assert Ok(#(p1)) = wayfinder.get_params1(route, segs)
          route.handler(p1)
          |> serve_html
        }
        Wrapper2(route) -> {
          let assert Ok(#(p1, p2)) = wayfinder.get_params2(route, segs)
          route.handler(p1, p2)
          |> serve_html
        }
      }
    }
  }
}

pub fn main() -> Nil {
  wayfinder.validate(routes)

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(_) =
    wisp_mist.handler(handle_request, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

pub fn home_handler() {
  html.div([], [])
}

pub fn post_all_handler() {
  html.div([], [])
}

pub fn post_handler(_id: String) {
  html.div([], [])
}

pub const home_route = Route0([], home_handler)

pub const post_all_route = Route0(
  [Literal("post"), Literal("all")],
  post_all_handler,
)

pub const post_route = Route1([Literal("post"), Param("id")], post_handler)

pub const routes = [
  Wrapper0(home_route),
  Wrapper0(post_all_route),
  Wrapper1(post_route),
]
