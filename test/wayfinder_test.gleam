import gleam/dict
import gleeunit
import gleeunit/should
import wayfinder

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn segs_to_route_test() {
  wayfinder.segs_to_route(routes(), ["undefined"])
  |> should.equal(Error(Nil))

  wayfinder.segs_to_route(routes(), [])
  |> should.equal(Ok(home_route()))

  wayfinder.segs_to_route(routes(), ["post", "all"])
  |> should.equal(Ok(post_all_route()))

  wayfinder.segs_to_route(routes(), ["post", "2"])
  |> should.equal(Ok(post_route()))

  wayfinder.segs_to_route(routes(), ["post", "2", "contacts", "2"])
  |> should.equal(Ok(contact_route()))
}

pub fn route_to_path_test() {
  wayfinder.route_to_path0(home_route(), Default([]))
  |> should.equal("/")

  wayfinder.route_to_path0(post_all_route(), Default([]))
  |> should.equal("/post/all")

  wayfinder.route_to_path0(post_all_route(), PostSearchParams("active"))
  |> should.equal("/post/all?filter=active")

  wayfinder.route_to_path1(post_route(), Default([]), "some_id")
  |> should.equal("/post/some_id")

  wayfinder.route_to_path2(contact_route(), Default([]), "some_id", "other_id")
  |> should.equal("/post/some_id/contacts/other_id")
}

pub fn validate_test() {
  wayfinder.do_validate([
    wayfinder.make_route1("/some/$id", search_params(), handler1),
  ])
  |> should.equal(Ok(Nil))

  wayfinder.do_validate([
    wayfinder.make_route0("/some/$id", search_params(), handler0),
  ])
  |> should.equal(Error("too many parameters: /some/$id"))

  wayfinder.do_validate([
    wayfinder.make_route2("/some/$id", search_params(), handler2),
  ])
  |> should.equal(Error("too few parameters: /some/$id"))
}

pub fn get_params1_test() {
  wayfinder.get_params1(
    wayfinder.make_route1("/some/$id", search_params(), handler1),
    ["some", "two"],
  )
  |> should.equal(Ok(#("two")))

  wayfinder.get_params1(
    wayfinder.make_route1("/some", search_params(), handler1),
    ["some", "two"],
  )
  |> should.equal(Error(Nil))
}

pub fn get_params2_test() {
  wayfinder.get_params2(
    wayfinder.make_route2("/some/$id/other/$id2", search_params(), handler2),
    ["some", "two", "other", "three"],
  )
  |> should.equal(Ok(#("two", "three")))
}

fn post_all_handler(params: SearchParams) {
  let assert PostSearchParams(filter) = params
  "<div>filter: " <> filter <> "</div>"
}

fn handler0(_params: SearchParams) {
  "<div></div>"
}

fn handler1(_params: SearchParams, _: String) {
  "<div></div>"
}

fn handler2(_params: SearchParams, _: String, _: String) {
  "<div></div>"
}

type SearchParams {
  Default(List(#(String, String)))
  PostSearchParams(filter: String)
}

fn search_params() -> wayfinder.SearchParams(SearchParams) {
  wayfinder.SearchParams(
    decode: fn(params) {
      let d = dict.from_list(params)
      case dict.get(d, "filter") {
        Error(_) -> Ok(Default(params))
        Ok(filter) -> Ok(PostSearchParams(filter))
      }
    },
    encode: fn(params) {
      case params {
        Default(params) -> params
        PostSearchParams(filter) -> [#("filter", filter)]
      }
    },
  )
}

fn home_route() {
  wayfinder.make_route0("/", search_params(), handler0)
}

fn post_all_route() {
  wayfinder.make_route0("/post/all", search_params(), post_all_handler)
}

fn post_route() {
  wayfinder.make_route1("/post/$id", search_params(), handler1)
}

fn contact_route() {
  wayfinder.make_route2(
    "/post/$post_id/contacts/$contact_id",
    search_params(),
    handler2,
  )
}

fn routes() {
  [home_route(), post_all_route(), post_route(), contact_route()]
}
