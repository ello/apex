defmodule Ello.V2.Manage.ImpressionCountController do
  use Ello.V2.Web, :controller
  alias Ello.V2.Manage
  alias Ello.{Auth, Grandstand}

  plug Auth.RequireUser
  plug Manage.OwnedArtistInvite

  def total(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    data = Grandstand.total_impressions(%{artist_invite: artist_invite})
    api_render(conn, data: data, artist_invite: artist_invite)
  end

  def daily(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    data = Grandstand.daily_impressions(%{artist_invite: artist_invite})
    api_render(conn, data: data, artist_invite: artist_invite)
  end
end
