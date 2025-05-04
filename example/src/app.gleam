import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/int
import lustre/attribute
import lustre/element
import lustre/element/html
import mist
import wayfinder
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
  let query = wisp.get_query(req)
  let response = wayfinder.segs_to_handler(segs, query, routes())

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

pub type SearchParams {
  Default(List(#(String, String)))
  PostAll(filter: String)
  PostPaginated(page: Int, per_page: Int)
}

fn strict_int() -> decode.Decoder(Int) {
  decode.string
  |> decode.then(fn(s) {
    case int.parse(s) {
      Ok(i) -> decode.success(i)
      Error(_) -> decode.failure(0, "Integer")
    }
  })
}

pub fn make_search_params() -> wayfinder.SearchParams(SearchParams) {
  wayfinder.SearchParams(
    decode: fn(params) {
      let post_all_decoder = {
        use filter <- decode.field("filter", decode.string)
        decode.success(PostAll(filter))
      }
      let post_paginated_decoder = {
        use page <- decode.field("page", strict_int())
        use per_page <- decode.field("per_page", strict_int())
        decode.success(PostPaginated(page, per_page))
      }
      let combined = decode.one_of(post_all_decoder, [post_paginated_decoder])

      let result =
        dict.from_list(params)
        |> dynamic.from
        |> decode.run(combined)

      case result {
        Error(_) -> Ok(Default(params))
        Ok(result) -> Ok(result)
      }
    },
    encode: fn(params) {
      case params {
        Default(params) -> params
        PostAll(filter) -> [#("filter", filter)]
        PostPaginated(page, per_page) -> [
          #("page", int.to_string(page)),
          #("per_page", int.to_string(per_page)),
        ]
      }
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

pub fn post_all_handler(params: SearchParams) {
  let assert PostAll(filter) = params

  html.div([], [
    html.div([], [html.text("filter: " <> filter)]),
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
