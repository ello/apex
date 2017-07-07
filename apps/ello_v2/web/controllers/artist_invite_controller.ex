defmodule Ello.V2.ArtistInviteController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  @doc """
  GET /v2/artist_invites
  """
  def index(conn, params) do
    api_render_if_stale(conn, data: artist_invites(conn, params))
  end

  defp artist_invites(conn, params),
    do: Contest.artist_invites(standard_params(conn))
end
