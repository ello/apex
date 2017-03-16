defmodule Ello.StreamTest do
  use Ello.Stream.Case
  alias Ello.Core.{Repo}
  alias Ello.Stream
  alias Ello.Stream.Item

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  test "returns 0 items when zero items in stream" do
    stream = Stream.fetch(
      keys: ["test"],
    )

    assert Enum.count(stream.posts) == 0
    assert stream.__batches == 1
  end

  test "it fetches from the stream" do
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post)
    post3 = Factory.insert(:post)
    roshi_items = [
      %Item{id: "#{post1.id}", stream_id: "test:1", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "test:1", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "test:2", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    stream = Stream.fetch(
      keys: ["test:1", "test:2"]
    )

    assert [_, _, _] = stream.posts
    assert Enum.any?(stream.posts, &(&1.id == post1.id))
    assert Enum.any?(stream.posts, &(&1.id == post2.id))
    assert Enum.any?(stream.posts, &(&1.id == post3.id))
    assert stream.per_page
    assert stream.before
  end

  test "only fetches [max] number of batches" do
    max_batches = Application.get_env(:ello_stream, :batches_per_request)
    num_good_posts = 10
    num_bad_posts = 1_000
    roshi_items = Enum.reduce(1..num_bad_posts, [], fn(_, items) ->
      id = Factory.insert(:post, %{is_adult_content: true, has_nudity: true}).id
      items ++ [%Item{id: "#{id}", stream_id: "test", ts: DateTime.utc_now}]
    end)
    Stream.Client.add_items(roshi_items)
    roshi_items = Enum.reduce(1..num_good_posts, [], fn(_, items) ->
      id = Factory.insert(:post).id
      items ++ [%Item{id: "#{id}", stream_id: "test", ts: DateTime.utc_now}]
    end)
    Stream.Client.add_items(roshi_items)

    stream = Stream.fetch(
      keys: ["test"],
      per_page: 10,
    )

    assert stream.__batches == max_batches
  end

  test "returns per_page items when that many items are available" do
    num_posts = 40
    per_page = 20
    roshi_items = Enum.reduce(1..num_posts, [], fn(_, items) ->
      id = Factory.insert(:post).id
      items ++ [%Item{id: "#{id}", stream_id: "test", ts: DateTime.utc_now}]
    end)
    Stream.Client.add_items(roshi_items)

    stream = Stream.fetch(
      keys: ["test"],
      per_page: per_page,
    )

    assert Enum.count(stream.posts) >= per_page
  end

  test "returns N < per_page items when only N items in stream" do
    num_posts = 10
    per_page = 20
    roshi_items = Enum.reduce(1..num_posts, [], fn(_, items) ->
      id = Factory.insert(:post).id
      items ++ [%Item{id: "#{id}", stream_id: "test", ts: DateTime.utc_now}]
    end)
    Stream.Client.add_items(roshi_items)

    stream = Stream.fetch(
      keys: ["test"],
      per_page: per_page,
    )

    assert Enum.count(stream.posts) == num_posts
    assert stream.__batches == 1
  end

  @tag :focus
  test "paginates" do
    num_posts = 100
    per_page = 10
    roshi_items = Enum.reduce(1..num_posts, [], fn(_, items) ->
      id = Factory.insert(:post).id
      items ++ [%Item{id: "#{id}", stream_id: "test", ts: DateTime.utc_now}]
    end)
    Stream.Client.add_items(roshi_items)

    page1 = Stream.fetch(
      keys: ["test"],
      per_page: per_page,
    )
    page2 = Stream.fetch(
      keys: ["test"],
      per_page: per_page,
      before: page1.before,
    )

    assert Enum.count(page1.posts) >= per_page
    assert Enum.count(page2.posts) >= per_page
    page1_ids = Enum.map(page1.posts, &(&1.id))
    page2_ids = Enum.map(page2.posts, &(&1.id))
    for post1_id <- page1_ids do
      for post2_id <- page2_ids do
        refute post1_id == post2_id
      end
    end
  end

end
