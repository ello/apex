defmodule Ello.Search.TermSanitizerTest do
  use Ello.Search.Case
  alias Ello.Search.TermSanitizer

  test "sanitize - does not change clean words" do
    results = TermSanitizer.sanitize("hello world")
    assert results = "hello world"
  end
end
