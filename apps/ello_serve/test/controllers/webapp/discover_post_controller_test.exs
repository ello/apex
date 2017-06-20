defmodule Ello.Serve.Webapp.DiscoverPostControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover - it renders", %{conn: conn} do
    resp = get(conn, "/discover")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Welcome .*")
  end

  @tag :meta
  test "/discover/trending - it renders", %{conn: conn} do
    resp = get(conn, "/discover/trending")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Explore trending .*")
  end

  @tag :meta
  test "/discover/recent - it renders", %{conn: conn} do
    resp = get(conn, "/discover/recent")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Discover recent .*")
  end
end
