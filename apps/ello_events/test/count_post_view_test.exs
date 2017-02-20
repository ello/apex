defmodule Ello.Events.CountPostViewTest do
  use ExUnit.Case
  alias Ello.Events.CountPostView
  doctest Ello.Events

  test "Exq implementation" do
    assert CountPostView.queue == "count"
    assert CountPostView.worker == "CountPostView"
    assert CountPostView.handler == Ello.Events.Exq
  end
end
