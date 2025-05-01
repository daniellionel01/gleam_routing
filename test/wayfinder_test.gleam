import gleam/dict
import gleam/result
import gleeunit
import gleeunit/should
import wayfinder.{Wrapper0, Wrapper1, Wrapper2}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn segs_to_route_test() {
  wayfinder.segs_to_route(routes(), ["undefined"])
  |> should.equal(Error(Nil))

  wayfinder.segs_to_route(routes(), [])
  |> should.equal(Ok(Wrapper0(home_route())))

  wayfinder.segs_to_route(routes(), ["post", "all"])
  |> should.equal(Ok(Wrapper0(post_all_route())))

  wayfinder.segs_to_route(routes(), ["post", "2"])
  |> should.equal(Ok(Wrapper1(post_route())))

  wayfinder.segs_to_route(routes(), ["post", "2", "contacts", "2"])
  |> should.equal(Ok(Wrapper2(contact_route())))
}

pub fn route_to_path_test() {
  wayfinder.route_to_path0(home_route(), [])
  |> should.equal("/")

  wayfinder.route_to_path0(post_all_route(), [])
  |> should.equal("/post/all")

  wayfinder.route_to_path1(post_route(), [], "some_id")
  |> should.equal("/post/some_id")

  wayfinder.route_to_path2(contact_route(), [], "some_id", "other_id")
  |> should.equal("/post/some_id/contacts/other_id")
}

pub fn validate_test() {
  wayfinder.do_validate([
    wayfinder.make_wrap1("/some/$id", params_decoder, handler1),
  ])
  |> should.equal(Ok(Nil))

  wayfinder.do_validate([
    wayfinder.make_wrap0("/some/$id", params_decoder, handler0),
  ])
  |> should.equal(Error("too many parameters: /some/$id"))

  wayfinder.do_validate([
    wayfinder.make_wrap2("/some/$id", params_decoder, handler2),
  ])
  |> should.equal(Error("too few parameters: /some/$id"))
}

pub fn get_params1_test() {
  wayfinder.get_params1(
    wayfinder.make_route1("/some/$id", params_decoder, handler1),
    ["some", "two"],
  )
  |> should.equal(Ok(#("two")))

  wayfinder.get_params1(
    wayfinder.make_route1("/some", params_decoder, handler1),
    ["some", "two"],
  )
  |> should.equal(Error(Nil))
}

pub fn get_params2_test() {
  wayfinder.get_params2(
    wayfinder.make_route2("/some/$id/other/$id2", params_decoder, handler2),
    ["some", "two", "other", "three"],
  )
  |> should.equal(Ok(#("two", "three")))
}

fn post_all_handler(params: PostSearchParams) {
  "<div>filter: " <> params.filter <> "</div>"
}

fn handler0(_params: wayfinder.DefaultSearchParams) {
  "<div></div>"
}

fn handler1(_params: wayfinder.DefaultSearchParams, _: String) {
  "<div></div>"
}

fn handler2(_params: wayfinder.DefaultSearchParams, _: String, _: String) {
  "<div></div>"
}

type PostSearchParams {
  PostSearchParams(filter: String)
}

fn post_search_params() {
  wayfinder.SearchParams(
    decode: fn(params) {
      let d = dict.from_list(params)
      use filter <- result.try(dict.get(d, "filter"))
      Ok(PostSearchParams(filter))
    },
    encode: fn(params) { [#("filter", params.filter)] },
  )
}

fn home_route() {
  wayfinder.make_route0("/", wayfinder.default_search_params(), handler0)
}

fn post_all_route() {
  wayfinder.make_route0("/post/all", post_search_params(), post_all_handler)
}

fn post_route() {
  wayfinder.make_route1(
    "/post/$id",
    wayfinder.default_search_params(),
    handler1,
  )
}

pub fn contact_route() {
  wayfinder.make_route2(
    "/post/$post_id/contacts/$contact_id",
    wayfinder.default_search_params(),
    handler2,
  )
}

fn routes() {
  [
    Wrapper0(home_route()),
    Wrapper0(post_all_route()),
    Wrapper1(post_route()),
    Wrapper2(contact_route()),
  ]
}
