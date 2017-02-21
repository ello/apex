defmodule Ello.V2.PostViewTracking do
  alias Ello.Events
  alias Ello.Events.CountPostView

  def track_post_view(%{assigns: assigns}, post) do
    user_id = case assigns[:current_user] do
      %{id: id} -> id
      _ -> nil
    end

    event = %CountPostView{
      post_ids: [post.id],
      user_id: user_id,
      stream_kind: "post",
    }
    Events.publish(event)
  end

end
