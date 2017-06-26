defmodule Ello.Serve.Webapp.UserControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user, username: "archer")
    {:ok, conn: conn, user: user}
  end

  @tag :meta
  test "it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer")
    html = html_response(resp, 200)
    assert html =~ "<title>@archer | Ello</title>"
    assert has_meta(html, name: "name", content: "@archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer")
    assert has_meta(html, name: "description", content: "See @archer.*s work on Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer")
    assert has_meta(html, property: "og:title", content: "@archer | Ello")
    assert has_meta(html, property: "og:description", content: "See @archer.*s work on Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end
end
