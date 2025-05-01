import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode

pub type Search {
  Search(name: String)
}

fn search_decoder() -> decode.Decoder(Search) {
  use name <- decode.field("name", decode.string)
  decode.success(Search(name:))
}

pub fn main() {
  let search = Search("david")

  decode.run(
    dynamic.from(dict.from_list([#("name", "david")])),
    search_decoder(),
  )
  |> echo
}
