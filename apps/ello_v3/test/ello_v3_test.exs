defmodule Ello.V3Test do
  use Ello.V3.Case
  use Plug.Test
  alias Ello.Auth.JWT

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    author = Factory.insert(:user, username: "author")
    post   = Factory.insert(:post, token: "token", author: author)
    user   = Factory.insert(:user, username: "current_user")

    query = """
      {
        post(token: "token", username: "author") {
          id
        }
      }
    """

    {:ok, post: post, query: query, user: user}
  end

  test "unauthenticated requests return 401", %{query: query} do
    resp = :post
           |> conn("/api/v3/graphql", %{query: query})
           |> put_req_header("content-type", "application/json")
           |> put_req_header("accepts", "application/json")
           |> Ello.V3.call([])

    assert resp.status == 401
  end

  test "authenticated public requests return 200", %{post: post, query: query} do
    resp = :post
           |> conn("/api/v3/graphql", %{query: query})
           |> put_req_header("content-type", "application/json")
           |> put_req_header("accepts", "application/json")
           |> put_req_header("authorization", "Bearer #{JWT.generate}")
           |> Ello.V3.call([])

    assert resp.status == 200
    assert resp.resp_body === ~s[{"data":{"post":{"id":"#{post.id}"}}}]
  end

  test "authenticated user requests return 200", %{post: post, query: query, user: user} do
    resp = :post
           |> conn("/api/v3/graphql", %{query: query})
           |> put_req_header("content-type", "application/json")
           |> put_req_header("accepts", "application/json")
           |> put_req_header("authorization", "Bearer #{JWT.generate(user)}")
           |> Ello.V3.call([])

    assert resp.status == 200
    assert resp.resp_body === ~s[{"data":{"post":{"id":"#{post.id}"}}}]
  end
end
