defmodule Ello.V2.CommentControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    post = Factory.insert(:post)
    comment1 = Factory.insert(:post, %{
      parent_post: post,
      created_at:  DateTime.from_unix!(100_000_000)
    })
    comment2 = Factory.insert(:post, %{
      parent_post: post,
      created_at:  DateTime.from_unix!(100_000_100)
    })
    Factory.add_assets(comment2)
    _comment3 = Factory.insert(:post, %{
      parent_post: post,
      created_at:  DateTime.from_unix!(100_000_200)
    })
    user = Factory.insert(:user)
    {:ok, conn: auth_conn(conn, user), post: post, comment: comment1}
  end

  test "GET /v2/posts/:id/comments", %{conn: conn, post: post} do
    resp = get(conn, "/api/v2/posts/#{post.id}/comments", %{"per_page" => "2"})
    json = json_response(resp, 200)
    assert [_, _] = json["comments"]

    assert [link] = get_resp_header(resp, "link")
    assert [_, url | _] = Regex.run(~r/<(.*?)>; rel="next"/, link)
    assert [_, before | _] = Regex.run(~r/[?&]before=(.*?)(&|$)/, url)

    resp2 = get(conn, "/api/v2/posts/#{post.id}/comments", %{"per_page" => "2", "before" => before})
    json2 = json_response(resp2, 200)
    assert [_] = json2["comments"]
  end

  @tag :json_schema
  test "GET /v2/posts/:id/comments - json schema", %{conn: conn, post: post} do
    resp = get(conn, "/api/v2/posts/#{post.id}/comments")
    assert :ok = validate_json("comment", json_response(resp, 200))
  end

  test "GET /v2/posts/:post_id/comments/:id", %{conn: conn, post: post, comment: comment} do
    resp = get(conn, "/api/v2/posts/#{post.id}/comments/#{comment.id}")
    json = json_response(resp, 200)
    assert %{"id" => _} = json["comments"]
  end

  @tag :json_schema
  test "GET /v2/posts/:post_id/comments/:id - json schema", %{conn: conn, post: post, comment: comment} do
    resp = get(conn, "/api/v2/posts/#{post.id}/comments/#{comment.id}")
    assert :ok = validate_json("comment", json_response(resp, 200))
  end
end
