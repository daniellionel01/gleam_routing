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

Wayfinder will look for a `ROUTES.lst` file. That file contains all of your routes and has the following schema:
```txt
name | path | module import name | handler call signature
```

- `name` is the name of the route, which will be converted to a custom type in pascal case. So "home" becomes "Home"
- `path` is fairly self explanatory. f.e. `/`, `/home`. Parameters are prefixed with a `$`, f.e. `/posts/$id`
- `module import name` is what the generator will put at the top of the file together with an `import ...`. so if the handler is located in `src/app/pages.gleam` it should be `app/pages`
- `handler call signature` this is how the generator calls the handler. it will take care of the parameters, so if the handler in the `app/pages` module is called `home_page`, then this should be `pages.home_page`

Here is a real world example:
```txt
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
