import lustre/element

pub type Route(a) {
  Route0(name: String, path: String, handler: fn() -> element.Element(a))
  Route1(name: String, path: String, handler: fn(String) -> element.Element(a))
  Route2(
    name: String,
    path: String,
    handler: fn(String, String) -> element.Element(a),
  )
  Route3(
    name: String,
    path: String,
    handler: fn(String, String, String) -> element.Element(a),
  )
  Route4(
    name: String,
    path: String,
    handler: fn(String, String, String, String) -> element.Element(a),
  )
  Route5(
    name: String,
    path: String,
    handler: fn(String, String, String, String, String) -> element.Element(a),
  )
  Route6(
    name: String,
    path: String,
    handler: fn(String, String, String, String, String, String) ->
      element.Element(a),
  )
  Route7(
    name: String,
    path: String,
    handler: fn(String, String, String, String, String, String, String) ->
      element.Element(a),
  )
  Route8(
    name: String,
    path: String,
    handler: fn(String, String, String, String, String, String, String, String) ->
      element.Element(a),
  )
  Route9(
    name: String,
    path: String,
    handler: fn(
      String,
      String,
      String,
      String,
      String,
      String,
      String,
      String,
      String,
    ) ->
      element.Element(a),
  )
}
