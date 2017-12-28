defmodule Ello.V2.Manage.ArtistInviteController do
  use Ello.V2.Web, :controller
  alias Ello.Auth.{RequireUser}
  alias Ello.Core.Contest

  plug RequireUser

  @doc """
  GET /v2/manage/artist_invites
  """
  def index(conn, _params) do
    artist_invites = Contest.my_artist_invites(standard_params(conn))
    api_render(conn, data: artist_invites)
  end

  def show(conn, %{"id" => id_or_slug}) do
    case fetch_artist_invite(conn, id_or_slug) do
      nil -> send_resp(conn, 403, "")
      artist_invite -> api_render(conn, data: artist_invite)
    end
  end

  defp fetch_artist_invite(conn, id_or_slug), do:
    Contest.my_artist_invite(standard_params(conn, %{id_or_slug: id_or_slug}))
end
