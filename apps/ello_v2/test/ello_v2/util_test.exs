defmodule Ello.V2.UnitTest do
  use ExUnit.Case
  alias Ello.V2.Util

  test "number_to_human - render 0", _ do
    assert Util.number_to_human(0) == "0"
  end

  test "number_to_human - render 123", _ do
    assert Util.number_to_human(123) == "123"
  end

  test "number_to_human - render 1_234", _ do
    assert Util.number_to_human(1_234) == "1.23K"
  end

  test "number_to_human - render 1_234, round 1", _ do
    assert Util.number_to_human(1_234, 1) == "1.2K"
  end

  test "number_to_human - render 1_000", _ do
    assert Util.number_to_human(1_000) == "1K"
  end

  test "number_to_human - render 12_345", _ do
    assert Util.number_to_human(12_345) == "12.35K"
  end

  test "number_to_human - render 123_454", _ do
    assert Util.number_to_human(123_454) == "123.45K"
  end

  test "number_to_human - render 123_001", _ do
    assert Util.number_to_human(123_001) == "123K"
  end

  test "number_to_human - render 1_234_567", _ do
    assert Util.number_to_human(1_234_567) == "1.23M"
  end

  test "number_to_human - render 123_456_789", _ do
    assert Util.number_to_human(123_456_789) == "123.46M"
  end

  test "number_to_human - render 1_234_567_890", _ do
    assert Util.number_to_human(1_234_567_890) == "1.23B"
  end

end
