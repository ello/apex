defmodule Ello.V3Test do
  use ExUnit.Case
  doctest Ello.V3

  test "greets the world" do
    assert Ello.V3.hello() == :world
  end
end
