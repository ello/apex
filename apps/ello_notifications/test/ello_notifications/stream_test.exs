defmodule Ello.Notifications.StreamTest do
  use Ello.Notifications.Case
  alias Ello.Notifications.Stream

  test "empty results" do
    user = Factory.insert(:user)
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})
  end
end
