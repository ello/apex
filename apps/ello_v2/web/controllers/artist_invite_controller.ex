defmodule Ello.V2.ArtistInviteController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  @doc """
  GET /v2/artist_invites
  """
  def index(conn, params) do
    artist_invites = Contest.artist_invites(standard_params(conn, %{
      preview: params["preview"],
    }))
    conn
    |> add_pagination_headers("/artist_invites", artist_invites)
    |> api_render_if_stale(data: artist_invites)
  end

  def show(conn, %{"id" => id_or_slug}) do
    artist_invite = Contest.artist_invite(standard_params(conn, %{
      id_or_slug: id_or_slug,
    }))
    api_render_if_stale(conn, data: artist_invite)
  end
end
