defmodule Ello.V2.Manage.SubmissionCountController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  plug Ello.Auth.RequireUser
  plug Manage.OwnedArtistInvite

  def total(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    data = Contest.total_submissions(%{artist_invite: artist_invite})
    api_render(conn, data: data, artist_invite: artist_invite)
  end

  def daily(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    data = Contest.daily_submissions(%{artist_invite: artist_invite})
    api_render(conn, data: data, artist_invite: artist_invite)
  end
end
