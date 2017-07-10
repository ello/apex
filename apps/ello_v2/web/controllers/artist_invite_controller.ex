defmodule Ello.V2.ArtistInviteController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  @doc """
  GET /v2/artist_invites
  """
  def index(conn, params) do
    artist_invites = conn
                     |> standard_params
                     |> Contest.artist_invites
    api_render_if_stale(conn, data: artist_invites)
  end

  def show(conn, %{"id" => id_or_slug}) do
    artist_invite = conn
                    |> standard_params(%{id_or_slug: id_or_slug})
                    |> Contest.artist_invite
    api_render_if_stale(conn, data: artist_invite)
  end
end
