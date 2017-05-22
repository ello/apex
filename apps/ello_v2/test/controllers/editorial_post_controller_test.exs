defmodule Ello.V2.EditorialPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post)
    post3 = Factory.insert(:post)

    {:ok, conn: auth_conn(conn, user), post1: post1, post2: post2, post3: post3}
  end

  test "GET /v2/editorials/posts", %{conn: conn, post1: p1, post2: p2} do
    response = get(conn, editorial_post_path(conn, :index), %{token: [p1.token, p2.token]})
    json = json_response(response, 200)
    returned_ids = Enum.map(json["posts"], &(String.to_integer(&1["id"])))
    assert p1.id in returned_ids
    assert p2.id in returned_ids
  end

  test "GET /v2/editorials/posts - no tokens", %{conn: conn} do
    response = get(conn, editorial_post_path(conn, :index))
    assert response.status == 204
  end

  @tag :json_schema
  test "GET /v2/editorials/posts - json schema", %{conn: conn, post1: p1, post2: p2} do
    response = get(conn, editorial_post_path(conn, :index), %{token: [p1.token, p2.token]})
    assert :ok = validate_json("post", json_response(response, 200))
  end
end
