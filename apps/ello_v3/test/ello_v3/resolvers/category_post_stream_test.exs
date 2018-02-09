defmodule Ello.V3.Resolvers.CategoryPostStreamTest do
  use Ello.V3.Case
  alias Ello.Stream
  alias Ello.Stream.Item

  @query """
    query($id: String, $slug: String, $perPage: String, $before: String) {
      categoryPostStream(id: $id, slug: $slug, before: $before, perPage: $perPage) {
        id
        slug
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

  test "Returns a stream of posts for a category - when using id", _ do
    Stream.Client.Test.start
    Stream.Client.Test.reset

    cat1  = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    post1 = Factory.insert(:post, category_ids: [cat1.id])
    post2 = Factory.insert(:post, category_ids: [cat1.id])
    post3 = Factory.insert(:post, category_ids: [cat1.id])
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{"id" => cat1.id, "perPage" => 3}})
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"posts" => posts, "next" => next, "isLastPage" => false} = json
    assert to_string(post1.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post2.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post3.id) in Enum.map(posts, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "id" => cat1.id,
      "before" => next,
      "perPage" => 3,
    }})
    assert %{"data" => %{"categoryPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json2
  end

  test "Returns a stream of posts for a category - when using slug", _ do
    Stream.Client.Test.start
    Stream.Client.Test.reset

    cat1  = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    post1 = Factory.insert(:post, category_ids: [cat1.id])
    post2 = Factory.insert(:post, category_ids: [cat1.id])
    post3 = Factory.insert(:post, category_ids: [cat1.id])
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{"slug" => cat1.slug, "perPage" => 3}})
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"posts" => posts, "next" => next, "isLastPage" => false} = json
    assert to_string(post1.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post2.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post3.id) in Enum.map(posts, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "slug" => cat1.slug,
      "before" => next,
      "perPage" => 3,
    }})
    assert %{"data" => %{"categoryPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json2
  end
end
