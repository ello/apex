defmodule Ello.V2.Manage.SubmissionCountController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  plug Ello.Auth.RequireUser
  plug Manage.OwnedArtistInvite

  def totals(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    # total = Contest.total_submissions(%{artist_invite: artist_invite})
    # IO.inspect(total)
    send_resp(conn, 200, "")
  end

  def daily(%{assigns: %{artist_invite: artist_invite}} = conn, _) do
    daily = Contest.daily_submissions(%{artist_invite: artist_invite})
    api_render(conn, data: daily, artist_invite: artist_invite)
  end


end
