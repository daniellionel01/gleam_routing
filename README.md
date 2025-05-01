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

```gleam
import lustre/attribute
import lustre/element/html
import wayfinder
import wisp

// --- --- --- DEFINE ROUTES --- --- ---

pub fn home_route() {
  wayfinder.make_route0("/", fn() { html.div([], [html.text("home")]) })
}

pub fn post_all_route() {
  wayfinder.make_route0("/post/all", post_all_handler())
}

pub fn post_route() {
  wayfinder.make_route1("/post/$id", fn(id: String) {
    html.div([], [html.text("post: " <> id)])
  })
}

pub fn routes() {
  [Wrapper0(home_route()), Wrapper0(post_all_route()), Wrapper1(post_route())]
}

// --- --- --- HANDLE WISP REQUESTS --- --- ---
fn handle_request(req: wisp.Request) {
  use req <- middleware(req)

  let segs = wisp.path_segments(req)
  let response = wayfinder.segs_to_handler(segs, routes())

  case response {
    Error(_) -> wisp.not_found()
    Ok(response) -> serve_html(response)
  }
}

// --- --- --- LINK PAGE IN HTML --- --- ---
pub fn post_all_handler() {
  html.div([], [
    html.a([attribute.href(wayfinder.route_to_path1(post_route(), "two"))], [
      html.text("post 1"),
    ]),
  ])
}
```

Checkout the [example](./example) for a minimal wisp web server setup.

## FAQ

### Is this production ready?

Yes! Feel free to use it in a serious project. I myself use it in side projects and at the company I work at in a production SaaS.

## License
[Apache License, Version 2.0](./LICENSE)
