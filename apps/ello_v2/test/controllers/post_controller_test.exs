defmodule Ello.PostControllerTest do
  use Ello.V2.ConnCase

  setup %{conn: conn} do
    post = Factory.insert(:post)
    user = Factory.insert(:user)
    {:ok, conn: auth_conn(conn, user), post: post}
  end

  test "GET /v2/posts/:id", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post))
    json = json_response(conn, 200)
    assert json["posts"]["id"] == "#{post.id}"
  end
end
