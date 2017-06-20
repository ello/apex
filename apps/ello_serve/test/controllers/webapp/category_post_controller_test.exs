defmodule Ello.Serve.Webapp.CategoryPostControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover/art - it renders", %{conn: conn} do
    resp = get(conn, "/discover/art")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end
end
