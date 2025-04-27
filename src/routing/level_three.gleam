import gleam/list
import gleam/string
import gleam/uri
import justin
import simplifile

pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

pub type RouterDefinition {
  RouterDefinition(
    alias: String,
    path: List(PathSegment),
    module: String,
    handler: String,
  )
}

pub fn path_to_segments(path: String) -> List(PathSegment) {
  path
  |> uri.path_segments()
  |> list.map(fn(seg) {
    case seg {
      "$" <> param -> Param(param)
      val -> Literal(val)
    }
  })
}

pub fn main() {
  let router_definitions =
    "
    home    | /            | routing/level_three | level_three.home
    profile | /profile/$id | routing/level_three | level_three.profile
"
  let router_dir = "./src/routing/gen/"
  let router_path = router_dir <> "router.gleam"

  let lines =
    router_definitions
    |> string.trim()
    |> string.split("\n")
    |> list.map(string.trim)

  let definitions =
    lines
    |> list.map(fn(line) {
      let assert [alias, path, module, handler] =
        line
        |> string.split("|")
        |> list.map(string.trim)
      let path = path_to_segments(path)
      let alias = justin.pascal_case(alias)
      RouterDefinition(alias, path, module, handler)
    })

  let gen_imports =
    definitions
    |> list.map(fn(def) { "import " <> def.module })
    |> list.unique()
    |> string.join("\n")

  let type_variants =
    definitions
    |> list.map(fn(def) {
      let params =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(_) -> ""
            Param(name) -> name <> ": String"
          }
        })
        |> list.filter(fn(s) { s != "" })
        |> string.join(", ")

      "  " <> def.alias <> "(" <> params <> ")"
    })
    |> string.join("\n")
  let gen_type_route = "pub type Route {\n" <> type_variants <> "\n}"

  let route_to_html_cases =
    definitions
    |> list.map(fn(def) {
      let params =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(_) -> ""
            Param(name) -> name
          }
        })
        |> list.filter(fn(s) { s != "" })
        |> string.join(", ")

      "    "
      <> def.alias
      <> "("
      <> params
      <> ") -> "
      <> def.handler
      <> "("
      <> params
      <> ")"
    })
    |> string.join("\n")
  let gen_route_to_html =
    string.trim(
      "pub fn route_to_html(route: Route) -> String {\n"
      <> "  case route {\n"
      <> route_to_html_cases
      <> "\n  }\n"
      <> "}",
    )

  let route_to_path_cases =
    definitions
    |> list.map(fn(def) {
      let params =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(_) -> ""
            Param(name) -> name
          }
        })
        |> list.filter(fn(s) { s != "" })
        |> string.join(", ")

      let path =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(val) -> "\"" <> val <> "/\""
            Param(name) -> name
          }
        })
        |> string.join(" <> ")
      let path = case path {
        "" -> "\"/\""
        path -> "\"/\" <> " <> path
      }

      "    " <> def.alias <> "(" <> params <> ") -> " <> path
    })
    |> string.join("\n")
  let gen_route_to_path =
    string.trim(
      "pub fn route_to_path(route: Route) -> String {\n"
      <> "  case route {\n"
      <> route_to_path_cases
      <> "\n  }\n"
      <> "}",
    )

  let segs_to_route_cases =
    definitions
    |> list.map(fn(def) {
      let params_left =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(val) -> "\"" <> val <> "\""
            Param(name) -> name
          }
        })
        |> string.join(", ")

      let params_right =
        def.path
        |> list.map(fn(seg) {
          case seg {
            Literal(_) -> ""
            Param(name) -> name
          }
        })
        |> list.filter(fn(s) { s != "" })
        |> string.join(", ")

      let params_right = case params_right {
        "" -> ""
        params_right -> {
          "(" <> params_right <> ")"
        }
      }

      "    ["
      <> params_left
      <> "]"
      <> " -> "
      <> "Ok("
      <> def.alias
      <> params_right
      <> ")"
    })
    |> string.join("\n")
  let gen_segs_to_route =
    string.trim(
      "pub fn segs_to_route(segs: List(String)) -> Result(Route, Nil) {\n"
      <> "  case segs {\n"
      <> segs_to_route_cases
      <> "\n    _ -> Error(Nil)\n"
      <> "  }\n"
      <> "}",
    )

  let generated_code =
    gen_imports
    <> "\n\n"
    <> gen_type_route
    <> "\n\n"
    <> gen_segs_to_route
    <> "\n\n"
    <> gen_route_to_html
    <> "\n\n"
    <> gen_route_to_path

  let _ = simplifile.create_directory_all(router_dir)
  let _ = simplifile.write(router_path, generated_code)

  Ok(Nil)
}

pub fn home() {
  "<div>homepage</div>"
}

pub fn profile(id: String) {
  "<div>id: " <> id <> "</div>"
}
