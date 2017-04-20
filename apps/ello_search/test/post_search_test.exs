defmodule Ello.Search.PostSearchTest do
  use Ello.Search.Case
  alias Ello.Search.{PostIndex, PostSearch}
  alias Ello.Core.{Repo, Factory}
  require IEx

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    post1 = Factory.insert(:post)
    PostIndex.delete
    PostIndex.create
    PostIndex.add(post1)
    {:ok,
      post1: post1,
    }
  end

  test "post_search - returns a relevant result", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post1.id
  end
end
