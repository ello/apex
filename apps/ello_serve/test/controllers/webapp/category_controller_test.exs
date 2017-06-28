defmodule Ello.Serve.Webapp.CategoryControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Factory.insert(:category, slug: "cat1", level: "primary")
    Factory.insert(:category, slug: "cat2", level: "primary")
    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover/all - meta", %{conn: conn} do
    resp = get(conn, "/discover/all")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end

  test "/discover/all - noscript", %{conn: conn} do
    resp = get(conn, "/discover/all")
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ ~r(<a href="https://ello.co/discover/cat1">)
    assert html =~ ~r(<a href="https://ello.co/discover/cat2">)
  end
end
