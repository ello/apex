defmodule Ello.V2.UserPostControllerTest do
  use Ello.V2.ConnCase, async: false

  setup %{conn: conn} do
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    posts = [
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
      Factory.insert(:post, %{author: author}),
    ]
    post = hd(posts)
    {:ok, conn: auth_conn(conn, user), user: user, author: author, posts: posts, post: post}
  end

  test "GET /v2/users/:id/posts", %{conn: conn, author: author} do
    conn = get(conn, user_post_path(conn, :index, author))
    assert conn.status == 200
  end

  test "GET /v2/users/:id/posts - returns page headers", %{conn: conn, author: author} do
    conn = get(conn, user_post_path(conn, :index, author), %{per_page: 2})
    assert get_resp_header(conn, "x-total-pages") == ["5"]
    assert get_resp_header(conn, "x-total-count") == ["1"]
    assert get_resp_header(conn, "x-total-pages-remaining") == ["1"]
  end

  test "GET /v2/users/:id/posts 404s", %{conn: conn} do
    conn = get(conn, user_post_path(conn, :index, "404"))
    assert conn.status == 404
  end

end
