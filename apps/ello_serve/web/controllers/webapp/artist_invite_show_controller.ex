defmodule Ello.Serve.Webapp.ArtistInviteShowController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Contest

  def show(conn, %{"id" => slug}) do
    case artist_invite(conn, slug) do
      nil ->
        if conn.assigns.logged_in_user? do
          render_html(conn)
        else
          send_resp(conn, 404, "")
        end
      invite -> render_html(conn, %{
        artist_invite: invite,
        submissions: fn -> submissions(conn, invite, "approved") end,
        selections:  fn -> submissions(conn, invite, "selected") end,
      })
    end
  end

  defp artist_invite(conn, slug),
    do: Contest.artist_invite(standard_params(conn, %{id_or_slug: "~#{slug}"}))

  defp submissions(conn, invite, status) do
    subs = Contest.artist_invite_submissions(standard_params(conn, %{
      invite: invite,
      status: status,
    }))
    track(conn, subs, stream_kind: "artist_invite_submissions", stream_id: invite.id)
    subs
  end
end
