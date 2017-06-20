defmodule Ello.Serve.Webapp.NoContentControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.VersionStore

  setup %{conn: conn} do
    raw2 = File.read!("test/support/ello.co.2.html")
    :ok = VersionStore.put_version(:webapp, "abc123", raw2)
    {:ok, conn: conn}
  end

  test "following - it renders - active version", %{conn: conn} do
    resp = get(conn, "/following")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert html =~ "@elloworld"
  end

  test "following - it renders - preview version", %{conn: conn} do
    resp = get(conn, "/following", %{"version" => "abc123"})
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert html =~ "@ellohype"
  end

  @tag :meta
  test "enter - it renders - active version", %{conn: conn} do
    resp = get(conn, "/enter")
    html = html_response(resp, 200)
    assert html =~ "Login | Ello"
    assert has_meta(html, name: "description", content: "Welcome back to Ello.*")
  end

  @tag :meta
  test "join - it renders - active version", %{conn: conn} do
    resp = get(conn, "/join")
    html = html_response(resp, 200)
    assert html =~ "Sign up | Ello"
    assert has_meta(html, name: "description", content: "Join .*")
  end

  @tag :meta
  test "forgot - it renders - active version", %{conn: conn} do
    resp = get(conn, "/forgot")
    html = html_response(resp, 200)
    assert html =~ "Forgot Password | Ello"
    assert has_meta(html, name: "description", content: "Welcome back .*")
  end

  @tag :meta
  test "default meta", %{conn: conn} do
    resp = get(conn, "/following")
    html = html_response(resp, 200)

    default_desc = "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about."
    default_title = "Ello | The Creators Network"
    default_image = "/static/images/support/ello-open-graph-image.png"

    assert html =~ "<title>Ello | The Creators Network</title>"
    assert has_meta(html, name: "apple-itunes-app", content: "app-id=1234567")
    assert has_meta(html, name: "name", content: default_title)
    assert has_meta(html, name: "url", content: "https://ello.co/following")
    assert has_meta(html, name: "description", content: default_desc)
    assert has_meta(html, name: "image", content: default_image)

    assert has_meta(html, property: "og:url", content: "https://ello.co/following")
    assert has_meta(html, property: "og:title", content: default_title)
    assert has_meta(html, property: "og:description", content: default_desc)

    assert has_meta(html, property: "og:image", content: default_image)
    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    refute has_meta(html, name: "robots")
  end
end
