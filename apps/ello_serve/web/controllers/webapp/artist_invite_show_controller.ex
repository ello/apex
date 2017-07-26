defmodule Ello.Serve.Webapp.ArtistInviteShowController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Contest

  def show(conn, %{"id" => id_or_slug}) do
    case artist_invite(conn, id_or_slug) do
      nil    -> send_resp(conn, 404, "")
      invite -> render_html(conn, %{
        artist_invite: invite,
        submissions: fn -> submissions(conn, id_or_slug) end,
      })
    end
  end

  defp artist_invite(conn, id_or_slug),
    do: Contest.artist_invite(%{id_or_slug: id_or_slug})

  defp submissions(conn, id_or_slug) do
    Contest.artist_invite_submissions(standard_params(conn, %{
      invite: Contest.artist_invite(%{id_or_slug: id_or_slug}),
      status: "approved",
    }))
  end
end
