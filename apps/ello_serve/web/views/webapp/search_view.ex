defmodule Ello.Serve.Webapp.SearchView do
  use Ello.Serve.Web, :view

  def render("noscript.html", %{type: "users"} = assigns),
    do: render_template("noscript.html", assigns)

  def render("noscript.html", assigns),
    do: render_template("noscript.html", assigns)

  def next_search_page_url(search, type) when type == "users" do
    webapp_url("search?type=users", page: search.next_page, terms: search.terms)
  end
  def next_search_page_url(search, _) do
    webapp_url("search", page: search.next_page, terms: search.terms)
  end
end
