import gleeunit
import gleeunit/should
import lustre/element/html
import wayfinder.{
  Literal, Param, Route0, Route1, Route2, Wrapper0, Wrapper1, Wrapper2,
}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn handler0() {
  html.div([], [])
}

pub fn handler1(_: String) {
  html.div([], [])
}

pub fn handler2(_: String, _: String) {
  html.div([], [])
}

pub fn handler3(_: String, _: String, _: String) {
  html.div([], [])
}

pub const home_route = Route0([], handler0)

pub const post_all_route = Route0([Literal("post"), Literal("all")], handler0)

pub const post_route = Route1([Literal("post"), Param("id")], handler1)

pub const contact_route = Route2(
  [Literal("post"), Param("post_id"), Literal("contacts"), Param("contact_id")],
  handler2,
)

pub const routes = [
  Wrapper0(home_route),
  Wrapper0(post_all_route),
  Wrapper1(post_route),
  Wrapper2(contact_route),
]

pub fn segs_to_route_test() {
  wayfinder.segs_to_route(routes, ["undefined"])
  |> should.equal(Error(Nil))

  wayfinder.segs_to_route(routes, [])
  |> should.equal(Ok(Wrapper0(home_route)))

  wayfinder.segs_to_route(routes, ["post", "all"])
  |> should.equal(Ok(Wrapper0(post_all_route)))

  wayfinder.segs_to_route(routes, ["post", "2"])
  |> should.equal(Ok(Wrapper1(post_route)))

  wayfinder.segs_to_route(routes, ["post", "2", "contacts", "2"])
  |> should.equal(Ok(Wrapper2(contact_route)))
}
