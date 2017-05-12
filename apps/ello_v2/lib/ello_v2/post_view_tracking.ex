defmodule Ello.V2.PostViewTracking do
  alias Ello.Events
  alias Ello.Events.CountPostView
  import NewRelicPhoenix, only: [measure_segment: 2]

  def track_post_view(conn, posts, opts \\ [])
  def track_post_view(conn, %{} = post, opts),
    do: track_post_view(conn, [post], opts)
  def track_post_view(%{assigns: assigns} = conn, posts, opts) do
    measure_segment {__MODULE__, "track_post_view"} do
      user_id = case assigns[:current_user] do
        %{id: id} -> id
        _ -> nil
      end

      post_ids = posts
                 |> Enum.reject(&is_nil/1)
                 |> Enum.map(&(&1.id))

      event = %CountPostView{
        post_ids:    post_ids,
        user_id:     user_id,
        stream_kind: opts[:stream_kind],
        stream_id:   "#{opts[:stream_id]}",
      }
      Events.publish(event)

      conn
    end
  end

end
