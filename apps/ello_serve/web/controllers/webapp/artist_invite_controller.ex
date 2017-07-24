defmodule Ello.Serve.Webapp.ArtistInviteController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Contest

  def index(conn, _) do
    render_html(conn, %{
      artist_invites: fn -> artist_invites(conn) end
    })
  end

  def show(conn, %{"id" => id_or_slug}) do
    render_html(conn, %{
      artist_invite: fn -> artist_invite(conn, id_or_slug) end,
      submissions: fn -> submissions(conn, id_or_slug) end,
    })
  end

  defp artist_invites(conn) do
    Contest.artist_invites(standard_params(conn))
  end

  defp artist_invite(conn, id_or_slug) do
    Contest.artist_invite(%{id_or_slug: id_or_slug})
  end

  defp submissions(conn, id_or_slug) do
    Contest.artist_invite_submissions(standard_params(conn, %{
      invite: Contest.artist_invite(%{id_or_slug: id_or_slug}),
      status: "approved",
    }))
  end
end
