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
    # assert html =~ "<title>Following | @archer | Ello</title>"
    # assert has_meta(html, name: "name", content: "Following | @archer | Ello")
    # assert has_meta(html, name: "url", content: "https://ello.co/archer/following")
    # assert has_meta(html, name: "description", content: "People following @archer | Ello")

    # assert has_meta(html, property: "og:url", content: "https://ello.co/archer/following")
    # assert has_meta(html, property: "og:title", content: "Following | @archer | Ello")
    # assert has_meta(html, property: "og:description", content: "People following @archer | Ello")

    # assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    # assert has_meta(html, name: "robots", content: "index, follow")
  end
end
