defmodule Ello.V2.FollowingPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Repo
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Core.{Redis}

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    user = Factory.insert(:user)
    {:ok, conn: auth_conn(conn, user), unauth_conn: conn, user: user}
  end

  test "GET /v2/following/posts/recent", %{conn: conn, user: user} do
    following_user = Factory.insert(:user)
    post = Factory.insert(:post, author: following_user)
    roshi_items = [
      %Item{id: "#{post.id}", stream_id: "#{following_user.id}", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    redis_key = "user:#{user.id}:followed_users_id_cache"
    Redis.command(["SADD", redis_key, following_user.id])

    response = get(conn, following_post_path(conn, :index))
    assert response.status == 200
  end

  test "GET /v2/following/posts/recent - fails for unauth requests", %{unauth_conn: conn} do
    response = get(conn, following_post_path(conn, :index))
    assert response.status == 401
  end

end
