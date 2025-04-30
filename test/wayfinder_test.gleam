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
  wayfinder.validate([wayfinder.make_wrap1("/some/$id", handler1)])
  |> should.equal([])

  wayfinder.validate([wayfinder.make_wrap0("/some/$id", handler0)])
  |> should.equal([wayfinder.TooManyParameters])

  wayfinder.validate([wayfinder.make_wrap2("/some/$id", handler2)])
  |> should.equal([wayfinder.MissingParameter])
}

pub fn get_params1_test() {
  wayfinder.get_params1(wayfinder.make_route1("/some/$id", handler1), [
    "some", "two",
  ])
  |> should.equal(Ok(#("two")))

  wayfinder.get_params1(wayfinder.make_route1("/some", handler1), [
    "some", "two",
  ])
  |> should.equal(Error(Nil))
}

pub fn get_params2_test() {
  wayfinder.get_params2(
    wayfinder.make_route2("/some/$id/other/$id2", handler2),
    ["some", "two", "other", "three"],
  )
  |> should.equal(Ok(#("two", "three")))
}

fn handler0() {
  "<div></div>"
}

fn handler1(_: String) {
  "<div></div>"
}

fn handler2(_: String, _: String) {
  "<div></div>"
}

fn home_route() {
  wayfinder.make_route0("/", handler0)
}

fn post_all_route() {
  wayfinder.make_route0("/post/all", handler0)
}

fn post_route() {
  wayfinder.make_route1("/post/$id", handler1)
}

pub fn contact_route() {
  wayfinder.make_route2("/post/$post_id/contacts/$contact_id", handler2)
}

fn routes() {
  [
    Wrapper0(home_route()),
    Wrapper0(post_all_route()),
    Wrapper1(post_route()),
    Wrapper2(contact_route()),
  ]
}
