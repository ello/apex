defmodule Ello.Search.PageTest do
  use Ello.Search.Case
  alias Ello.Search.Page

  test "from_results - handles empty results gracefully", _ do
    results = %{"_shards" => %{"failed" => 0, "successful" => 5,
      "total" => 5}, "hits" => %{"hits" => [], "max_score" => nil, "total" => 0},
    "timed_out" => false, "took" => 2}

     assert Page.pagination_builder(%Ello.Search.Post.Search{__raw_results: results})
  end
end
