import gleam/int
import gleam/list
import gleam/result
import gleam/uri

pub type CampaignsSearch {
  CampaignsSearch(rows: Int, page: Int)
}

pub type Route {
  Home
  Profile(id: String)
  Campaigns(search: CampaignsSearch)
}

pub fn route_to_path(route: Route) {
  case route {
    Home -> "/"
    Profile(id) -> "/profile/" <> id
    Campaigns(search) -> {
      let CampaignsSearch(rows, page) = search
      let rows = int.to_string(rows)
      let page = int.to_string(page)
      let search = uri.query_to_string([#("rows", rows), #("page", page)])
      "/campaigns/" <> search
    }
  }
}

pub fn segs_to_route(segs: List(String)) -> Result(Route, Nil) {
  case segs {
    [] -> Ok(Home)
    ["profile", id] -> Ok(Profile(id))
    ["campaigns", search] -> {
      use search <- result.try(uri.parse_query(search))

      use rows <- result.try(list.find(search, fn(s) { s.0 == "rows" }))
      use page <- result.try(list.find(search, fn(s) { s.0 == "page" }))

      use rows <- result.try(int.parse(rows.1))
      use page <- result.try(int.parse(page.1))

      Ok(Campaigns(CampaignsSearch(rows, page)))
    }
    _ -> Error(Nil)
  }
}

pub fn route_to_html(route: Route) -> String {
  case route {
    Home -> home()
    Profile(id) -> profile(id)
    Campaigns(search) -> campaigns(search)
  }
}

pub fn handler(segs: List(String)) -> String {
  case segs_to_route(segs) {
    Ok(route) -> {
      route_to_html(route)
    }
    Error(_) -> "404"
  }
}

pub fn home() -> String {
  todo as "home page html"
}

pub fn profile(_id: String) -> String {
  todo as "profile page html"
}

pub fn campaigns(_search: CampaignsSearch) -> String {
  todo as "campaigns page html"
}
