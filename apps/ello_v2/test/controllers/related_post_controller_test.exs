defmodule Ello.V2.RelatedPostControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    author = Factory.insert(:user)
    posts = Enum.map 1..10, fn (_) ->
      Factory.insert(:post, author: author)
    end
    current_user = Factory.insert(:user)
    {:ok, conn: auth_conn(conn, current_user), posts: posts}
  end

  test "GET /v2/posts/:id/related", %{conn: conn, posts: posts} do
    post = Enum.random(posts)
    conn = get(conn, post_related_path(conn, :index, post))
    json = json_response(conn, 200)
    returned_ids = json["posts"]
                   |> Enum.map(&(String.to_integer(&1["id"])))
                   |> MapSet.new

    created_ids = posts
                  |> Enum.map(&(&1.id))
                  |> MapSet.new

    assert MapSet.subset?(returned_ids, created_ids)
    refute post.id in returned_ids
  end

  test "GET /v2/posts/:id/related - no related posts", %{conn: conn} do
    post = Factory.insert(:post)
    resp = get(conn, post_related_path(conn, :index, post))
    assert resp.status == 204
  end

  test "GET /v2/posts/:id/related - no post", %{conn: conn} do
    resp = get(conn, post_related_path(conn, :index, "0"))
    assert resp.status == 404
  end
end
