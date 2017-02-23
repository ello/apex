defmodule Ello.V2.PostViewTracking do
  alias Ello.Events
  alias Ello.Events.CountPostView

  def track_post_view(conn, %{} = post),
    do: track_post_view(conn, [post])
  def track_post_view(%{assigns: assigns}, posts) do
    user_id = case assigns[:current_user] do
      %{id: id} -> id
      _ -> nil
    end

    event = %CountPostView{
      post_ids: Enum.map(posts, &(&1.id)),
      user_id: user_id,
      stream_kind: "post",
    }
    Events.publish(event)
  end

end
