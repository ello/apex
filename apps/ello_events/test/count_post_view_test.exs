defmodule Ello.Events.CountPostViewTest do
  use ExUnit.Case
  alias Ello.Events.CountPostView
  doctest Ello.Events

  test "Sidekiq implementation" do
    assert CountPostView.queue == "count"
    assert CountPostView.worker == "CountPostView"
    assert CountPostView.handler == Ello.Events.Sidekiq
  end

  test "Event.publish/1 - publishes a CountPostView" do
    pid = self()
    listener = fn(command) ->
      send pid, command
    end

    Application.put_env(:ello_events, :redis, listener)
    Ello.Events.publish(%CountPostView{
      post_ids: [1, 2, 3],
      user_id: 666,
      stream_kind: "following",
      stream_id: nil,
    })

    assert_receive ["LPUSH", "sidekiq:queue:count", json]
    assert %{"args" => [%{"post_ids" => [1, 2, 3]}]} = Jason.decode!(json)

    Application.delete_env(:ello_events, :redis)
  end
end
