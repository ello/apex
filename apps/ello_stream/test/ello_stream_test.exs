defmodule Ello.StreamTest do
  use ExUnit.Case
  alias Ello.Stream

  test "it fetches from the stream" do
    stream = Stream.fetch(
      keys: ["test:1", "test:2"]
    )

    assert [post1, post2, post3] = stream.posts
  end

end
