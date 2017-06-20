defmodule Ello.Serve.Webapp.EditorialControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  @tag :meta
  test "editorial - it renders", %{conn: conn} do
    resp = get(conn, "/")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Welcome .*")
  end
end
