defmodule Ello.Events.CountPostViewTest do
  use ExUnit.Case
  alias Ello.Events.CountPostView
  doctest Ello.Events

  test "Exq implementation" do
    assert CountPostView.queue == "count"
    assert CountPostView.worker == "CountPostView"
    assert CountPostView.handler == Ello.Events.Exq
  end

  defmacro with_test_env(app, key, value, do: tests) do
    quote do
      restore_env = Application.get_env(unquote(app), unquote(key))
      Application.put_env(unquote(app), unquote(key), unquote(value))
      unquote(tests)
      Application.put_env(unquote(app), unquote(key), restore_env)
    end
  end

  test "Event.publish/1 - publishes a CountPostView" do
    with_test_env(:ello_events, :exq_process, self()) do
      spawn fn ->
        Ello.Events.publish(%CountPostView{
          post_ids: [1, 2, 3],
          current_user_id: 666,
          stream_kind: "following",
          stream_id: nil,
        })
      end

      assert_receive {_, _, {
        :enqueue,
        "count",
        "CountPostView",
        [
          %{
            current_user_id: 666,
            post_ids: [1, 2, 3],
            stream_id: nil,
            stream_kind: "following"
          }
        ],
        _
      }}
    end
  end
end
