pub type PathSegment {
  Literal(val: String)
  Param(name: String)
}

pub type SearchParams(a) {
  SearchParams(
    decode: fn(List(#(String, String))) -> Result(a, Nil),
    encode: fn(a) -> List(#(String, String)),
  )
}

pub type Handler(a, b) {
  Handler0(fn(b) -> a)
  Handler1(fn(b, String) -> a)
  Handler2(fn(b, String, String) -> a)
}

pub type Route(a, b) {
  Route(
    path: List(PathSegment),
    search: SearchParams(b),
    handler: Handler(b, a),
  )
}
