defmodule Ello.Serve.Webapp.CategoryControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover/all - it renders", %{conn: conn} do
    resp = get(conn, "/discover/all")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end
end
