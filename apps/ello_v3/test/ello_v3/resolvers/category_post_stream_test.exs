defmodule Ello.V3.Resolvers.CategoryPostStreamTest do
  use Ello.V3.Case
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Search.Post.Index

  @query """
    query($kind: StreamKind!, $id: String, $slug: String, $perPage: String, $before: String) {
      categoryPostStream(kind: $kind, id: $id, slug: $slug, before: $before, perPage: $perPage) {
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

  test "Featured stream - when using the id", _ do
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

    resp = post_graphql(%{query: @query, variables: %{"id" => cat1.id, "kind" => "FEATURED", "perPage" => 3}})
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"posts" => posts, "next" => next, "isLastPage" => false} = json
    assert to_string(post1.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post2.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post3.id) in Enum.map(posts, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "id" => cat1.id,
      "kind" => "FEATURED",
      "before" => next,
      "perPage" => 3,
    }})
    assert %{"data" => %{"categoryPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json2
  end

  test "Featured stream - when using the slug", _ do
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

    resp = post_graphql(%{query: @query, variables: %{"slug" => cat1.slug, "perPage" => 3, "kind" => "FEATURED"}})
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"posts" => posts, "next" => next, "isLastPage" => false} = json
    assert to_string(post1.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post2.id) in Enum.map(posts, &(&1["id"]))
    assert to_string(post3.id) in Enum.map(posts, &(&1["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "slug" => cat1.slug,
      "kind" => "FEATURED",
      "before" => next,
      "perPage" => 3,
    }})
    assert %{"data" => %{"categoryPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json2
  end

  test "Trending stream", _ do
    cat1  = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    posts = Factory.insert_list(6, :post, %{category_ids: [cat1.id]})
    Index.delete
    Index.create
    Enum.each(posts, &Index.add/1)

    resp = post_graphql(%{query: @query, variables: %{"id" => cat1.id, "kind" => "TRENDING", "perPage" => 3}})
    assert %{"data" => %{"categoryPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => [_p1, _p2, _p3]} = json

    resp2 = post_graphql(%{query: @query, variables: %{
      "id" => cat1.id,
      "before" => next,
      "kind" => "TRENDING",
      "perPage" => 3,
    }})
    assert %{"data" => %{"categoryPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => nil, "posts" => [_p1, _p2, _p3]} = json2
  end
end
