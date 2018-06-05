defmodule Ello.V3.Resolvers.CommentStreamTest do
  use Ello.V3.Case

  @query """
    query($id: String, $token: String, $perPage: String, $before: String) {
      commentStream(id: $id, token: $token, before: $before, perPage: $perPage) {
        comments { id }
        next
        isLastPage
      }
    }
  """

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    :ok
  end

  test "Comment stream - when using the id", _ do
    post = Factory.insert(:post)
    comment1 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_000)})
    comment2 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_100)})
    comment3 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_200)})

    resp = post_graphql(%{query: @query, variables: %{"id" => post.id, "perPage" => 3}})
    assert %{"data" => %{"commentStream" => json}} = json_response(resp)
    assert %{"comments" => comments, "next" => next, "isLastPage" => false} = json
    assert to_string(comment3.id) in Enum.map(comments, &(&1["id"]))
    assert to_string(comment2.id) in Enum.map(comments, &(&1["id"]))
    assert to_string(comment1.id) in Enum.map(comments, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{"id" => post.id, "before" => next, "perPage" => 3}})
    assert %{"data" => %{"commentStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "comments" => []} = json2
  end

  test "Comment stream - when using the post token", _ do
    post = Factory.insert(:post)
    comment1 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_000)})
    comment2 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_100)})
    comment3 = Factory.insert(:comment, %{parent_post: post, created_at:  DateTime.from_unix!(100_000_200)})

    resp = post_graphql(%{query: @query, variables: %{"token" => "~#{post.token}", "perPage" => 3}})
    assert %{"data" => %{"commentStream" => json}} = json_response(resp)
    assert %{"comments" => comments, "next" => next, "isLastPage" => false} = json
    assert to_string(comment3.id) in Enum.map(comments, &(&1["id"]))
    assert to_string(comment2.id) in Enum.map(comments, &(&1["id"]))
    assert to_string(comment1.id) in Enum.map(comments, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{"token" => "~#{post.token}", "before" => next, "perPage" => 3}})
    assert %{"data" => %{"commentStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "comments" => []} = json2
  end
end
