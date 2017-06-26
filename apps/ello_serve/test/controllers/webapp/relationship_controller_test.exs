defmodule Ello.Serve.Webapp.RelationshipControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user, username: "archer")
    {:ok, conn: conn, user: user}
  end

  @tag :meta
  test "/:username/following - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer/following")
    html = html_response(resp, 200)
    assert html =~ "<title>Following | @archer | Ello</title>"
    assert has_meta(html, name: "name", content: "Following | @archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer/following")
    assert has_meta(html, name: "description", content: "People following @archer | Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer/following")
    assert has_meta(html, property: "og:title", content: "Following | @archer | Ello")
    assert has_meta(html, property: "og:description", content: "People following @archer | Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  @tag :meta
  test "/:username/followers - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer/followers")
    html = html_response(resp, 200)
    assert html =~ "<title>Followers | @archer | Ello</title>"
    assert has_meta(html, name: "name", content: "Followers | @archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer/followers")
    assert has_meta(html, name: "description", content: "People followed by @archer | Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer/followers")
    assert has_meta(html, property: "og:title", content: "Followers | @archer | Ello")
    assert has_meta(html, property: "og:description", content: "People followed by @archer | Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end
end
