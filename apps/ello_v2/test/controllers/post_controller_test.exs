defmodule Ello.V2.PostControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    post = Factory.insert(:post)
    user = Factory.insert(:user)
    {:ok, conn: auth_conn(conn, user), post: post}
  end

  test "GET /v2/posts/:id", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post))
    json = json_response(conn, 200)
    assert json["posts"]["id"] == "#{post.id}"
  end

  test "GET /v2/posts/:id - 304", %{conn: conn, post: post} do
    resp = get(conn, post_path(conn, :show, post))
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(post_path(conn, :show, post))
    assert resp2.status == 304
    post
    |> Ecto.Changeset.change(%{updated_at: DateTime.utc_now})
    |> Ello.Core.Repo.update!
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(post_path(conn, :show, post))
    assert resp3.status == 200
  end

  test "GET /v2/posts/:id, user_id - success", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post), %{"user_id" => "#{post.author.id}"})
    json = json_response(conn, 200)
    assert json["posts"]["id"] == "#{post.id}"
  end

  test "GET /v2/posts/:id, user_token - success", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post), %{"user_id" => "~#{post.author.username}"})
    json = json_response(conn, 200)
    assert json["posts"]["id"] == "#{post.id}"
  end

  @tag :json_schema
  test "GET /v2/posts/:id - json schema", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post))
    assert :ok = validate_json("post", json_response(conn, 200))
  end

  test "GET /v2/posts/:id, user_id - failure", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post), %{"user_id" => "#{post.author.id + 1}"})
    assert conn.status == 404
  end

  test "GET /v2/posts/:id, user_token - failure", %{conn: conn, post: post} do
    conn = get(conn, post_path(conn, :show, post), %{"user_id" => "~i made this up"})
    assert conn.status == 404
  end

  test "GET /v2/posts/:id 404s", %{conn: conn} do
    conn = get(conn, post_path(conn, :show, "404"))
    assert conn.status == 404
  end
end
