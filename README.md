# Wayfinder: Typesafe Routing in Gleam

[![Package Version](https://img.shields.io/hexpm/v/wayfinder)](https://hex.pm/packages/wayfinder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wayfinder/)

## Introduction

This is a package to generate a typesafe router for a gleam web server. It generates a gleam file that provides a typesafe wrapper around your type definitions:
- `Route` type that abstracts your routes
- `route_to_path` function to convert a `Route` to a path that can be used for a `href`
- `segs_to_route` function to match router segments (f.e. in a wisp server) to the correct `Route`
- `route_to_html` function to match a `Route` to a handler function to render the HTML

## Gleam Targets

Works for both `javascript` and `erlang` target!

## Usage

```bash
$ gleam add wayfinder # install package
$ gleam run -m wayfinder # generate router from definitions
```

## FAQ

### Is this production ready?

Yes! Feel free to use it in a serious project. I myself use it in side projects and at the company I work at in a production SaaS.

### What features are missing?

Loads! Here are some ideas for people to contribute:
- Typesafe search query definitions
- Create router definitions with gleam code

## License
[Apache License, Version 2.0](./LICENSE)
