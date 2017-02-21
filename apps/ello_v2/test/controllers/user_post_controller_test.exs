defmodule Ello.V2.UserPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Redis

  setup %{conn: conn} do
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, %{author: author})
    {:ok, conn: auth_conn(conn, user), user: user, author: author, post: post}
  end

  test "GET /v2/users/:id/posts", %{conn: conn, author: author, post: post} do
    conn = get(conn, user_post_path(conn, :index, author))
    assert conn.status == 200
  end

end
