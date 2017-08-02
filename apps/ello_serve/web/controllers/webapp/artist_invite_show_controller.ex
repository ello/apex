defmodule Ello.Serve.Webapp.ArtistInviteShowController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Contest

  def show(conn, %{"id" => slug}) do
    case artist_invite(conn, slug) do
      nil    -> send_resp(conn, 404, "")
      invite -> render_html(conn, %{
        artist_invite: invite,
        submissions: fn -> submissions(conn, slug) end,
      })
    end
  end

  defp artist_invite(conn, slug),
    do: Contest.artist_invite(standard_params(conn, %{id_or_slug: "~#{slug}"}))

  defp submissions(conn, slug) do
    Contest.artist_invite_submissions(standard_params(conn, %{
      invite: Contest.artist_invite(%{id_or_slug: "~#{slug}"}),
      status: "approved",
    }))
  end
end
