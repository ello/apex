defmodule Ello.Serve.Webapp.SearchControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @tag :meta
  test "/search - it renders", %{conn: conn} do
    resp = get(conn, "/search", %{terms: "ello"})
    html = html_response(resp, 200)
    assert html =~ "Search | Ello"
    assert has_meta(html, name: "description", content: "Find work .*")
  end

  @tag :meta
  test "/search?type=users - it renders", %{conn: conn} do
    resp = get(conn, "/search", %{"terms" => "ello", "type" => "users"})
    html = html_response(resp, 200)
    assert html =~ "Search | Ello"
    assert has_meta(html, name: "description", content: "Find creators.*")
  end
end
