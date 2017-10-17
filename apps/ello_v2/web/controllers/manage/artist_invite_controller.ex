defmodule Ello.V2.Manage.ArtistInviteController do
  use Ello.V2.Web, :controller
  alias Ello.Auth.{RequireUser}
  alias Ello.Core.Contest
  alias Ello.V2.{ArtistInviteView}

  plug RequireUser

  @doc """
  GET /v2/manage/artist_invites
  """
  def index(conn, _params) do
    artist_invites = Contest.artist_invites(standard_params(conn, %{
      preview: false
    }))
    conn
    |> api_render_if_stale(ArtistInviteView, :index, data: artist_invites)
  end
end
