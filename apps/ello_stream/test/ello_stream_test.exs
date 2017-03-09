defmodule Ello.StreamTest do
  use ExUnit.Case
  alias Ello.Stream
  alias Ello.Stream.Item

  test "it fetches from the stream" do
    Stream.Client.add_items([
      %Item{id: "1", stream_id: "test:1", ts: DateTime.utc_now},
      %Item{id: "2", stream_id: "test:1", ts: DateTime.utc_now},
      %Item{id: "3", stream_id: "test:2", ts: DateTime.utc_now},
    ])

    stream = Stream.fetch(
      keys: ["test:1", "test:2"]
    )

    assert [post1, post2, post3] = stream.posts
  end

end
