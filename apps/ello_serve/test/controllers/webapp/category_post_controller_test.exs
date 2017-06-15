defmodule Ello.Serve.Webapp.CategoryPostControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    raw = File.read!("test/support/ello.co.html")
    Redis.command(["SET", "ello_serve:webapp:current", raw])
    on_exit fn() ->
      Redis.command(["DEL", "ello_serve:webapp:current"])
    end
    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover/art - it renders", %{conn: conn} do
    resp = get(conn, "/discover/art")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end
end
