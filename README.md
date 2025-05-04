# Wayfinder: Typesafe Routing in Gleam

[![Package Version](https://img.shields.io/hexpm/v/wayfinder)](https://hex.pm/packages/wayfinder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wayfinder/)

## Introduction

This is a package to generate a typesafe router for a gleam web server.

It also provides a typesafe method of linking to paths, so you don't link to invalid pages.

Zero dependencies and works for both `javascript` and `erlang` target!

### "Typesafe" Disclaimer

In theory, this library is not fully typesafe, since you could pass arbitrary strings into the route and are not guaranteed to have matching arguments. For example you could make `/profile/$id` a route2. However this is why this library also includes a `validate` function, which traverses your path and checks if it has the exact number of arguments based on the path segments.

## Usage

```bash
$ gleam add wayfinder # install package
```

<details>

<summary>
  <h3>Simple Example</h3>
</summary>

```gleam
import gleam/dicimport lustre/attribute
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
```
<details>


<details>

<summary>
  <h3>Complex Example (with search parameters)</h3>
</summary>

```gleam
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import lustre/attribute
import lustre/element
import lustre/element/html
import wayfinder
import wisp

// --- --- --- DECODE HELPER --- --- ---

fn strict_int() -> decode.Decoder(Int) {
  decode.string
  |> decode.then(fn(s) {
    case int.parse(s) {
      Ok(i) -> decode.success(i)
      Error(_) -> decode.failure(0, "Integer")
    }
  })
}

// --- --- --- DEFINE ROUTES --- --- ---

pub type SearchParams {
  Default(List(#(String, String)))
  PostAll(filter: String)
  PostPaginated(page: Int, per_page: Int)
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
```

</details>

Checkout the [example](./example) for a minimal wisp web server setup.

## FAQ

### Is this production ready?

Yes! Feel free to use it in a serious project. I myself use it in side projects and at the company I work at in a production SaaS.

## License
[Apache License, Version 2.0](./LICENSE)
