defmodule Ello.Search.PageTest do
  use Ello.Search.Case
  alias Ello.Core.{Repo, Factory, Network}
  alias Ello.Search.{Page, UserSearch, UserIndex}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    UserIndex.delete
    UserIndex.create
    {:ok, %{}}
  end

  test "from_results - handles empty results gracefully", _ do
    results = %{"_shards" => %{"failed" => 0, "successful" => 5,
      "total" => 5}, "hits" => %{"hits" => [], "max_score" => nil, "total" => 0},
    "timed_out" => false, "took" => 2}

     assert Page.from_results(results, [], %{})
  end
end
