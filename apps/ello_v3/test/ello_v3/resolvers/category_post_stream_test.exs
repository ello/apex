defmodule Ello.V3.Resolvers.CategoryPostStreamTest do
  use Ello.V3.Case
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Search.Post.Index

  @query """
    query($perPage: String, $before: String) {
      categoryPostStream(before: $before, kind: $kind, perPage: $perPage) {
        next
        isLastPage
        posts { id }
      }
    }
  """

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    :ok
  end

  test "Returns a stream of posts for a category", _ do
    Stream.Client.Test.start
    Stream.Client.Test.reset

    cat1  = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    post1 = Factory.insert(:post, category_ids: [cat1.id])
    post2 = Factory.insert(:post, category_ids: [cat1.id])
    post3 = Factory.insert(:post, has_nudity: true, category_ids: [cat1.id])
    post4 = Factory.insert(:post)
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{"perPage" => 2)
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => [_p1, _p2]} = json

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "perPage" => 2,
    }})
    assert %{"data" => %{"globalPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => [_p3]} = json2
  end
end
