defmodule Ello.V2.CategoryPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Repo
  alias Ello.Stream
  alias Ello.Stream.Item

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    Factory.insert(:category, slug: "cat1")
    Factory.insert(:category, slug: "cat2")

    user = Factory.insert(:user)
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post)
    post3 = Factory.insert(:post, has_nudity: true)
    post4 = Factory.insert(:post)
    post5 = Factory.insert(:post)
    post6 = Factory.insert(:post, has_nudity: true)
    Factory.insert(:love, post: post1, user: user)
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    {:ok, [
      conn: auth_conn(conn, user),
      posts: [post1, post2, post3, post4, post5, post6],
    ]}
  end

  test "GET /v2/categories/:slug/posts/recent", %{conn: conn, posts: posts} do
    response = conn
               |> assign(:allow_nudity, true)
               |> get(category_post_path(conn, :recent, "cat1"))
    assert response.status == 200
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    [p1, p2, p3, p4, p5, p6] = posts
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    assert p3.id in returned_ids
    refute p4.id in returned_ids
    refute p5.id in returned_ids
    refute p6.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  test "GET /v2/categories/:slug/posts/recent - no nudity", %{conn: conn, posts: posts} do
    response = conn
               |> assign(:allow_nudity, false)
               |> get(category_post_path(conn, :recent, "cat1"))
    assert response.status == 200
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    [p1, p2, p3, p4, p5, p6] = posts
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    refute p3.id in returned_ids
    refute p4.id in returned_ids
    refute p5.id in returned_ids
    refute p6.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  @tag :json_schema
  test "GET /v2/following/posts/recent - json schema", %{conn: conn} do
    conn = get(conn, category_post_path(conn, :recent, "cat1"))
    assert :ok = validate_json("post", json_response(conn, 200))
  end
end
