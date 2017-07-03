defmodule Ello.Feeds.EditorialController do
  use Ello.Feeds.Web, :controller
  import Ello.Events.TrackPostViews
  alias Ello.Core.Discovery

  def index(conn, _params) do
    editorials = editorials(conn)
    conn
    |> track(editorials, steam_kind: "editorials_via_#{get_format(conn)}")
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
end
