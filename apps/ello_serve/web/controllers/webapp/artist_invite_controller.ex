defmodule Ello.Serve.Webapp.ArtistInviteController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Contest

  def index(conn, _) do
    render_html(conn, %{
      artist_invites: fn -> artist_invites(conn) end
    })
  end

  defp artist_invites(conn) do
    Contest.artist_invites(standard_params(conn))
  end
end
