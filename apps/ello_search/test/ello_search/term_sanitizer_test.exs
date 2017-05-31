defmodule Ello.Search.TermSanitizerTest do
  use Ello.Search.Case
  alias Ello.Search.TermSanitizer

  test "sanitize - does not change clean words" do
    assert %{terms: "hello world"} =
      TermSanitizer.sanitize(%{terms: "hello world"})
  end

  test "sanitize - removes dirty words" do
    assert %{terms: "hello world, "} =
      TermSanitizer.sanitize(%{terms: "hello world, asshole"})
  end

  test "sanitize - removes dirty words if hashtagged" do
    assert %{terms: "hello world, "} =
      TermSanitizer.sanitize(%{terms: "hello world, #asshole"})
  end
end
