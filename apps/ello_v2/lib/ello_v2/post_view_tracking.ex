defmodule Ello.V2.PostViewTracking do
  alias Ello.Events.TrackPostViews

  def track_post_view(conn, posts, opts),
    do: TrackPostViews.track(conn, posts, opts)
end
