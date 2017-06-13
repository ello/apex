defmodule Ello.Serve.Webapp.PostControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Core.{
    Redis,
    Repo,
  }

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    raw = File.read!("test/support/ello.co.html")
    raw2 = File.read!("test/support/ello.co.2.html")
    Redis.command(["SET", "ello_serve:webapp:current", raw])
    Redis.command(["SET", "ello_serve:webapp:abc123", raw2])
    on_exit fn() ->
      Redis.command(["DEL", "ello_serve:webapp:current"])
      Redis.command(["DEL", "ello_serve:webapp:abc123"])
    end
    author = Factory.insert(:user, username: "archer")
    Factory.insert(:post, author: author, token: "abc123")
    {:ok, conn: conn, raw: raw}
  end

  test "it renders - active version", %{conn: conn} do
    resp = get(conn, "/archer/post/abc123")
    html = html_response(resp, 200)
    assert html =~ "test post"
    assert html =~ "@elloworld"
    assert html =~ "Phrasing!"
  end

  test "it 404s if user not found", %{conn: conn} do
    resp = get(conn, "/bob/post/abc123")
    assert resp.status == 404
  end

  test "it 404s if post not found", %{conn: conn} do
    resp = get(conn, "/archer/post/wrong")
    assert resp.status == 404
  end
end
