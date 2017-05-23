defmodule Ello.Search.TermSanitizerTest do
  use Ello.Search.Case
  alias Ello.Search.TermSanitizer

  test "sanitize - does not change clean words" do
    assert TermSanitizer.sanitize("hello world") == "hello world"
  end

  test "sanitize - removes dirty words" do
    assert TermSanitizer.sanitize("hello world, asshole") == "hello world, "
  end

  test "sanitize - removes dirty words if hashtagged" do
    assert TermSanitizer.sanitize("hello world, #asshole") == "hello world, "
  end
end
