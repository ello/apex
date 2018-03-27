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
    cposts1 = Factory.insert_list(6, :category_post, %{category: context.cat1})
    cposts2 = Factory.insert_list(6, :category_post, %{category: context.cat2})
    posts1 = Enum.map(cposts1, &(&1.post))
    posts2 = Enum.map(cposts2, &(&1.post))
    Index.delete
    Index.create
    Enum.each(posts1 ++ posts2, &Index.add/1)

    resp = post_graphql(%{query: @query, variables: %{"kind" => "TRENDING", "perPage" => 3}}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert length(posts_resp1) === 3
    Enum.each posts_resp1, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{context.cat1.id}"
    end

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "TRENDING",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => nil, "posts" => posts_resp2} = json2
    assert length(posts_resp2) === 3
    Enum.each posts_resp2, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{context.cat1.id}"
    end
  end

  test "Trending stream - not subscribed to anything", context do
    user = Factory.insert(:user, %{followed_category_ids: nil})
    cposts1 = Factory.insert_list(6, :category_post, %{category: context.cat1})
    cposts2 = Factory.insert_list(6, :category_post, %{category: context.cat2})
    posts1 = Enum.map(cposts1, &(&1.post))
    posts2 = Enum.map(cposts2, &(&1.post))
    Index.delete
    Index.create
    Enum.each(posts1 ++ posts2, &Index.add/1)

    resp = post_graphql(%{query: @query, variables: %{"kind" => "TRENDING", "perPage" => 3}}, user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => true, "next" => nil, "posts" => []} = json
  end

  test "Featured stream", context do
    Stream.Client.Test.start
    Stream.Client.Test.reset
    %{cat1: cat1, cat2: cat2} = context

    post1 = Factory.insert(:featured_category_post, category: cat1).post
    post2 = Factory.insert(:featured_category_post, category: cat1).post
    post3 = Factory.insert(:featured_category_post, category: cat1).post
    post4 = Factory.insert(:featured_category_post, category: cat1).post
    post5 = Factory.insert(:featured_category_post, category: cat2).post
    post6 = Factory.insert(:featured_category_post, category: cat2).post
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: Stream.key(cat1, :featured), ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: Stream.key(cat1, :featured), ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: Stream.key(cat1, :featured), ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: Stream.key(cat1, :featured), ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: Stream.key(cat2, :featured), ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: Stream.key(cat2, :featured), ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "FEATURED",
      "perPage" => 3
    }}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert length(posts_resp1) === 3
    Enum.each posts_resp1, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "FEATURED",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => posts_resp2} = json2
    assert length(posts_resp2) === 1
    Enum.each posts_resp2, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end
  end

  test "Recent stream", context do
    Stream.Client.Test.start
    Stream.Client.Test.reset
    %{cat1: cat1, cat2: cat2} = context

    post1 = Factory.insert(:category_post, category: cat1).post
    post2 = Factory.insert(:category_post, category: cat1).post
    post3 = Factory.insert(:category_post, category: cat1).post
    post4 = Factory.insert(:category_post, category: cat1).post
    post5 = Factory.insert(:category_post, category: cat2).post
    post6 = Factory.insert(:category_post, category: cat2).post
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: Stream.key(cat1, :recent), ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: Stream.key(cat1, :recent), ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: Stream.key(cat1, :recent), ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: Stream.key(cat1, :recent), ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: Stream.key(cat2, :recent), ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: Stream.key(cat2, :recent), ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "RECENT",
      "perPage" => 3
    }}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert length(posts_resp1) === 3
    Enum.each posts_resp1, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "RECENT",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => posts_resp2} = json2
    assert length(posts_resp2) === 1
    Enum.each posts_resp2, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end
  end

  test "Shop stream", context do
    Stream.Client.Test.start
    Stream.Client.Test.reset
    %{cat1: cat1, cat2: cat2} = context

    post1 = Factory.insert(:category_post, category: cat1).post
    post2 = Factory.insert(:category_post, category: cat1).post
    post3 = Factory.insert(:category_post, category: cat1).post
    post4 = Factory.insert(:category_post, category: cat1).post
    post5 = Factory.insert(:category_post, category: cat2).post
    post6 = Factory.insert(:category_post, category: cat2).post
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: Stream.key(cat1, :shop), ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: Stream.key(cat1, :shop), ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: Stream.key(cat1, :shop), ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: Stream.key(cat1, :shop), ts: DateTime.utc_now},
      %Item{id: "#{post5.id}", stream_id: Stream.key(cat2, :shop), ts: DateTime.utc_now},
      %Item{id: "#{post6.id}", stream_id: Stream.key(cat2, :shop), ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "SHOP",
      "perPage" => 3
    }}, context.user)
    assert %{"data" => %{"subscribedPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => posts_resp1} = json
    assert length(posts_resp1) === 3
    Enum.each posts_resp1, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end

    resp2 = post_graphql(%{query: @query, variables: %{
      "before" => next,
      "kind" => "SHOP",
      "perPage" => 3,
    }}, context.user)

    assert %{"data" => %{"subscribedPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "posts" => posts_resp2} = json2
    assert length(posts_resp2) === 1
    Enum.each posts_resp2, fn(post_json) ->
      assert hd(post_json["categories"])["id"] === "#{cat1.id}"
    end
  end
end
