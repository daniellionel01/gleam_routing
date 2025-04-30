# Wayfinder: Typesafe Routing in Gleam

[![Package Version](https://img.shields.io/hexpm/v/wayfinder)](https://hex.pm/packages/wayfinder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/wayfinder/)

## Introduction

This is a package to generate a typesafe router for a gleam web server. It also provides static analysis to ensure you have not missed adding a route.

Works for both `javascript` and `erlang` target!

## Usage

```bash
$ gleam add wayfinder # install package
$ gleam run -m wayfinder # run static analysis
```

- `name` is the name of the route, which will be converted to a custom type in pascal case. So "home" becomes "Home"
- `path` is fairly self explanatory. f.e. `/`, `/home`. Parameters are prefixed with a `$`, f.e. `/posts/$id`

### Static Analysis

- find unused routes

## FAQ

### Is this production ready?

Yes! Feel free to use it in a serious project. I myself use it in side projects and at the company I work at in a production SaaS.

### What features are missing?

Loads! Here are some ideas for people to contribute:
- Typesafe search query definitions
- Create router definitions with gleam code

## License
[Apache License, Version 2.0](./LICENSE)
