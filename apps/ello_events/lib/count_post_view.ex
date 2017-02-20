defmodule Ello.Events.CountPostView do
  use Ello.Events.Exq

  defstruct [
    post_ids: [],
    current_user_id: nil,
    stream_kind: nil,
    stream_id: nil
  ]

  def queue, do: "count"
  def args(post_view) do
    [
      Map.from_struct(post_view),
    ]
  end

end
