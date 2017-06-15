defmodule Ello.Serve.Webapp.EditorialControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    raw = File.read!("test/support/ello.co.html")
    Redis.command(["SET", "ello_serve:webapp:current", raw])
    on_exit fn() ->
      Redis.command(["DEL", "ello_serve:webapp:current"])
    end
    {:ok, conn: conn, raw: raw}
  end

  @tag :meta
  test "editorial - it renders", %{conn: conn} do
    resp = get(conn, "/")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Welcome .*")
  end
end
