import gleeunit
import gleeunit/should
import lustre/element/html
import wayfinder.{Route0, Route1, Route2, Wrapper0, Wrapper1, Wrapper2}

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
  wayfinder.route_to_path0(home_route())
  |> should.equal("/")

  wayfinder.route_to_path0(post_all_route())
  |> should.equal("/post/all")

  wayfinder.route_to_path1(post_route(), "some_id")
  |> should.equal("/post/some_id")

  wayfinder.route_to_path2(contact_route(), "some_id", "other_id")
  |> should.equal("/post/some_id/contacts/other_id")
}

pub fn validate_test() {
  wayfinder.validate([
    Wrapper1(Route1(wayfinder.path_to_segments("/some/$id"), handler1)),
  ])
  |> should.equal([])

  wayfinder.validate([
    Wrapper0(Route0(wayfinder.path_to_segments("/some/$id"), handler0)),
  ])
  |> should.equal([wayfinder.TooManyParameters])

  wayfinder.validate([
    Wrapper2(Route2(wayfinder.path_to_segments("/some/$id"), handler2)),
  ])
  |> should.equal([wayfinder.MissingParameter])
}

fn handler0() {
  html.div([], [])
}

fn handler1(_: String) {
  html.div([], [])
}

fn handler2(_: String, _: String) {
  html.div([], [])
}

fn home_route() {
  Route0(wayfinder.path_to_segments("/"), handler0)
}

fn post_all_route() {
  Route0(wayfinder.path_to_segments("/post/all"), handler0)
}

fn post_route() {
  Route1(wayfinder.path_to_segments("/post/$id"), handler1)
}

pub fn contact_route() {
  Route2(
    wayfinder.path_to_segments("/post/$post_id/contacts/$contact_id"),
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
