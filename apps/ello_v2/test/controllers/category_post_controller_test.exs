defmodule Ello.V2.CategoryPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Repo
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Search.Post.Index

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    cat1 = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    cat2 = Factory.insert(:category, roshi_slug: "cat2", slug: "cat2", level: "primary")
    inv1 = Factory.insert(:artist_invite, status: "open")
    inv2 = Factory.insert(:artist_invite, status: "open")
    inv3 = Factory.insert(:artist_invite, status: "closed")

    user = Factory.insert(:user)
    post1 = Factory.insert(:featured_category_post, category: cat1).post
    post2 = Factory.insert(:featured_category_post, category: cat1).post
    post3 = Factory.insert(:post, has_nudity: true)
    Factory.insert(:featured_category_post, post: post3, category: cat1)
    post4 = Factory.insert(:featured_category_post, category: cat2).post
    post5 = Factory.insert(:featured_category_post, category: cat2).post
    post6 = Factory.insert(:post, has_nudity: true)
    Factory.insert(:featured_category_post, post: post6, category: cat2)
    post7 = Factory.insert(:post)
    post8 = Factory.insert(:post, has_nudity: true)
    post9 = Factory.insert(:post)
    Factory.insert(:artist_invite_submission, post: post7, artist_invite: inv1)
    Factory.insert(:artist_invite_submission, post: post8, artist_invite: inv2)
    Factory.insert(:artist_invite_submission, post: post9, artist_invite: inv3)
    Factory.insert(:love, post: post1, user: user)
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post7.id}", stream_id: "artist_invite:v1:#{inv1.id}", ts: DateTime.utc_now},
      %Item{id: "#{post8.id}", stream_id: "artist_invite:v1:#{inv2.id}", ts: DateTime.utc_now},
      %Item{id: "#{post9.id}", stream_id: "artist_invite:v1:#{inv3.id}", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    {:ok, [
      conn: auth_conn(conn, user),
      posts: [post1, post2, post3, post4, post5, post6, post7, post8, post9],
    ]}
  end

  test "GET /v2/categories/:slug/posts/recent", %{conn: conn, posts: posts} do
    response = conn
               |> assign(:allow_nudity, true)
               |> get(category_post_path(conn, :recent, "cat1"))
    assert response.status == 200
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    [p1, p2, p3, p4, p5, p6 | _] = posts
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
    [p1, p2, p3, p4, p5, p6 | _] = posts
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    refute p3.id in returned_ids
    refute p4.id in returned_ids
    refute p5.id in returned_ids
    refute p6.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  @tag :json_schema
  test "GET /v2/categoreis/:slug/posts/recent - json schema", %{conn: conn} do
    conn = get(conn, category_post_path(conn, :recent, "cat1"))
    assert :ok = validate_json("post", json_response(conn, 200))
  end

  test "GET /v2/categories/posts/recent", %{conn: conn, posts: posts} do
    response = conn
               |> assign(:allow_nudity, true)
               |> get(category_post_path(conn, :featured))
    assert response.status == 200
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    [p1, p2, p3, p4, p5, p6, p7, p8, p9] = posts
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    assert p3.id in returned_ids
    assert p4.id in returned_ids
    assert p5.id in returned_ids
    assert p6.id in returned_ids
    assert p7.id in returned_ids
    assert p8.id in returned_ids
    refute p9.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  test "GET /v2/categories/posts/recent - no nudity", %{conn: conn, posts: posts} do
    response = conn
               |> assign(:allow_nudity, false)
               |> get(category_post_path(conn, :featured))
    assert response.status == 200
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    [p1, p2, p3, p4, p5, p6, p7, p8, p9] = posts
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    refute p3.id in returned_ids
    assert p4.id in returned_ids
    assert p5.id in returned_ids
    refute p6.id in returned_ids
    assert p7.id in returned_ids
    refute p8.id in returned_ids
    refute p9.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  @tag :json_schema
  test "GET /v2/categories/posts/recent - json schema", %{conn: conn} do
    conn = get(conn, category_post_path(conn, :featured))
    assert :ok = validate_json("post", json_response(conn, 200))
  end

  test "GET /v2/categories/:slug/posts/trending", %{conn: conn, posts: posts} do
    Enum.each(posts, &Index.add/1)
    response = get(conn, category_post_path(conn, :trending, "cat1"))
    assert response.status == 200
    json = json_response(response, 200)
    [p1, p2, p3, p4, p5, p6 | _] = posts
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    assert p1.id in returned_ids
    assert p2.id in returned_ids
    assert p3.id in returned_ids
    refute p4.id in returned_ids
    refute p5.id in returned_ids
    refute p6.id in returned_ids
    assert Enum.find(json["posts"], &(&1["loved"] == true))
  end

  @tag :json_schema
  test "GET /v2/categories/:slug/posts/trending - json schema", %{conn: conn, posts: posts} do
    Enum.each(posts, &Index.add/1)
    conn = get(conn, category_post_path(conn, :trending, "cat1"))
    assert :ok = validate_json("post", json_response(conn, 200))
  end
end
