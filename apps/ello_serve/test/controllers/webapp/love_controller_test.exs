defmodule Ello.Serve.Webapp.LoveControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user, username: "archer")
    {:ok, conn: conn, user: user}
  end

  @tag :meta
  test "/:username/loves - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer/loves")
    html = html_response(resp, 200)
    assert html =~ "<title>Posts loved by @archer | Ello</title>"
    assert has_meta(html, name: "name", content: "Loves | @archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer/loves")
    assert has_meta(html, name: "description", content: "Posts loved by @archer | Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer/loves")
    assert has_meta(html, property: "og:title", content: "Posts loved by @archer | Ello")
    assert has_meta(html, property: "og:description", content: "Posts loved by @archer | Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end
end
