defmodule Ello.Feeds.EditorialController do
  use Ello.Feeds.Web, :controller
  alias Ello.Events
  alias Ello.Core.Discovery

  def index(conn, _params) do
    editorials = editorials(conn)
    conn
    |> track_post_views(editorials)
    |> render(:index, data: editorials)
  end

  defp editorials(_conn) do
    Discovery.editorials(%{
      allow_nudity: false,
      allow_nsfw:   false,
      current_user: nil,
      preview:      false,
      per_page:     100,
      before:       nil,
      kinds:        ["post", "internal", "external"],
    })
  end

  defp track_post_views(conn, editorials) do
    post_ids = editorials
               |> Enum.map(&(&1.post))
               |> Enum.reject(&is_nil/1)
               |> Enum.map(&(&1.id))

    Events.publish(%Events.CountPostView{
      post_ids:    post_ids,
      user_id:     nil,
      stream_kind: "editorials_via_#{get_format(conn)}",
      stream_id:   "",
    })
    conn
  end
end

