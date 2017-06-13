defmodule Ello.Serve.Webapp.NoContentControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Core.Redis

  setup %{conn: conn} do

    raw = File.read!("test/support/ello.co.html")
    raw2 = File.read!("test/support/ello.co.2.html")
    Redis.command(["SET", "ello_serve:webapp:current", raw])
    Redis.command(["SET", "ello_serve:webapp:abc123", raw2])
    on_exit fn() ->
      Redis.command(["DEL", "ello_serve:webapp:current"])
      Redis.command(["DEL", "ello_serve:webapp:abc123"])
    end
    {:ok, conn: conn, raw: raw}
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

  test "settings - it renders - active version", %{conn: conn} do
    resp = get(conn, "/settings")
    html = html_response(resp, 200)
    assert html =~ "Tweak yo shit"
  end
end
