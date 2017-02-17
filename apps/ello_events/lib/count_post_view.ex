defmodule Ello.Events.CountPostView do
  use Ello.Events.Exq

  defstruct [
    ids: [],
    current_user_id: nil,
    stream_kind: nil,
    stream_id: nil
  ]

  @override
  def queue, do: "count"
  def args(post_view) do
    [
      %{
        post_ids: post_view.ids,
        user_id: post_view.current_user.id,
        stream_kind: post_view.stream_kind,
        stream_id: post_view.stream_id
      }
    ]
  end
end
