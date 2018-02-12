defmodule Ello.V3.Resolvers.SubscribedPostStreamTest do
  use Ello.V3.Case
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Search.Post.Index

  @query """
    query($perPage: String, $before: String, $kind: StreamKind!) {
      subscribedPostStream(before: $before, kind: $kind, perPage: $perPage) {
        next
        isLastPage
        posts { id, categories { id } }
      }
    }
  """

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset
    cat1 = Factory.insert(:category, roshi_slug: "cat1", slug: "cat1", level: "primary")
    cat2 = Factory.insert(:category, roshi_slug: "cat2", slug: "cat2", level: "primary")
    user = Factory.insert(:user, %{followed_category_ids: [cat1.id]})

    {:ok, %{user: user, cat1: cat1, cat2: cat2}}
  end

  test "Trending stream", context do
    posts1 = Factory.insert_list(6, :post, %{category_ids: [context.cat1.id]})
    posts2 = Factory.insert_list(6, :post, %{category_ids: [context.cat2.id]})
    Index.delete
    Index.create
    Enum.each(posts1 ++ posts2, &Index.add/1)

    resp = post_graphql(%{query: @query, variables: %{"kind" => "TRENDING", "perPage" => 3}}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert List.duplicate(to_string(context.cat1.id), 3) == Enum.map(posts_resp1, &(hd(&1["categories"])["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "TRENDING",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => nil, "posts" => posts_resp2} = json2
    assert List.duplicate(to_string(context.cat1.id), 3) == Enum.map(posts_resp2, &(hd(&1["categories"])["id"]))
  end

  test "Featured stream", context do
    Stream.Client.Test.start
    Stream.Client.Test.reset

    post1 = Factory.insert(:post, %{category_ids: [context.cat1.id]})
    post2 = Factory.insert(:post, %{category_ids: [context.cat1.id]})
    post3 = Factory.insert(:post, %{category_ids: [context.cat1.id]})
    post4 = Factory.insert(:post, %{category_ids: [context.cat1.id]})
    post5 = Factory.insert(:post, %{category_ids: [context.cat2.id]})
    post6 = Factory.insert(:post, %{category_ids: [context.cat2.id]})
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: "categories:v1:cat2", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{"kind" => "FEATURED", "perPage" => 3}}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert List.duplicate(to_string(context.cat1.id), 3) == Enum.map(posts_resp1, &(hd(&1["categories"])["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "FEATURED",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => posts_resp2} = json2
    assert [to_string(context.cat1.id)] == Enum.map(posts_resp2, &(hd(&1["categories"])["id"]))
  end
end
