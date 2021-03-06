defmodule Ello.Serve.Webapp.PostControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Core.{
    Repo,
  }

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    author = Factory.insert(:user, username: "archer", bad_for_seo?: false)
    Factory.add_assets(Factory.insert(:post, author: author, token: "abc123"))
    author2 = Factory.insert(:user, username: "lana", bad_for_seo?: true)
    Factory.insert(:post, author: author2, token: "def345")
    {:ok, conn: conn}
  end

  test "it renders - active version", %{conn: conn} do
    resp = get(conn, "/archer/post/abc123")
    html = html_response(resp, 200)
    assert html =~ "test post"
    assert html =~ "@elloworld"
  end

  test "it 404s if user not found", %{conn: conn} do
    resp = get(conn, "/bob/post/abc123")
    assert resp.status == 404
  end

  test "it 404s if user is private and user is not known", %{conn: conn} do
    author2 = Factory.insert(:user, username: "private", is_public: false)
    Factory.insert(:post, author: author2, token: "ghi789")
    resp = get(conn, "/private/post/ghi789")
    assert resp.status == 404
  end

  test "it 200s if user is private and user is known", %{conn: conn} do
    author2 = Factory.insert(:user, username: "private", is_public: false)
    Factory.insert(:post, author: author2, token: "ghi789")

    resp = conn
           |> put_req_cookie("ello_skip_prerender", "true")
           |> get("/private/post/ghi789")
    assert resp.status == 200
  end

  test "it 404s if post not found", %{conn: conn} do
    resp = get(conn, "/archer/post/wrong")
    assert resp.status == 404
  end

  @tag :meta
  test "meta attributes - with images", %{conn: conn} do
    resp = get(conn, "/archer/post/abc123")
    html = html_response(resp, 200)
    assert html =~ "<title>test post</title>"
    assert has_meta(html, name: "apple-itunes-app", content: "app-id=1234567, app-argument=/archer/post/abc123")
    assert has_meta(html, name: "name", content: "test post")
    assert has_meta(html, name: "url", content: "https://ello.co/archer/post/abc123")
    assert has_meta(html, name: "description", content: "Phrasing!")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer/post/abc123")
    assert has_meta(html, property: "og:title", content: "test post")
    assert has_meta(html, property: "og:description", content: "Phrasing!")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")

    asset_hdpi_url = "https://assets.ello.co/uploads/asset/attachment/.*/ello-hdpi-.*.jpg"
    assert has_meta(html, name: "image", content: asset_hdpi_url)
    assert has_meta(html, property: "og:image", content: asset_hdpi_url)
    assert has_meta(html, name: "image", content: asset_hdpi_url)
    assert has_meta(html, property: "og:image", content: asset_hdpi_url)
  end

  @tag :meta
  test "meta attributes - no images", %{conn: conn} do
    resp = get(conn, "/lana/post/def345")
    html = html_response(resp, 200)
    assert html =~ "<title>test post</title>"
    assert has_meta(html, name: "apple-itunes-app", content: "app-id=1234567, app-argument=/lana/post/def345")
    assert has_meta(html, name: "name", content: "test post")
    assert has_meta(html, name: "url", content: "https://ello.co/lana/post/def345")
    assert has_meta(html, name: "description", content: "Phrasing!")

    assert has_meta(html, property: "og:url", content: "https://ello.co/lana/post/def345")
    assert has_meta(html, property: "og:title", content: "test post")
    assert has_meta(html, property: "og:description", content: "Phrasing!")

    assert has_meta(html, name: "twitter:card", content: "summary")
    assert has_meta(html, name: "robots", content: "noindex, follow")

    refute has_meta(html, name: "image")
    refute has_meta(html, property: "og:image")
  end
end
