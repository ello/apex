defmodule Ello.Serve.Webapp.RelationshipControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user = Factory.insert(:user, username: "archer")
    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
    {:ok, conn: conn, user: user, user1: user1, user2: user2}
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

  test "/:username/following - it renders noscript", %{conn: conn, user: user, user1: user1, user2: user2} do
    Factory.insert(:relationship, owner: user, subject: user1)
    Factory.insert(:relationship, owner: user, subject: user2)

    resp = get(conn, "/archer/following", %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "<h2>@archer</h2>"
    assert html =~ "<h2>@#{user1.username()}</h2>"
    assert html =~ "<h2>@#{user2.username()}</h2>"
  end

  test "/:username/followers - it renders noscript", %{conn: conn, user: user, user1: user1, user2: user2} do
    Factory.insert(:relationship, owner: user1, subject: user)
    Factory.insert(:relationship, owner: user2, subject: user)

    resp = get(conn, "/archer/followers", %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "<h2>@archer</h2>"
    assert html =~ "<h2>@#{user1.username()}</h2>"
    assert html =~ "<h2>@#{user2.username()}</h2>"
  end
end
