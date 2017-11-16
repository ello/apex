defmodule Ello.V2.Manage.OwnedArtistInvite do
  @behaviour Plug
  import Plug.Conn
  alias Ello.Core.Contest
  import Ello.V2.StandardParams

  def init(opts), do: opts

  def call(conn, _) do
    case fetch_artist_invite(conn) do
      nil    -> halt send_resp(conn, 404, "")
      invite -> assign(conn, :artist_invite, invite)
    end
  end

  defp fetch_artist_invite(%{params: %{"artist_invite_id" => id}} = conn), do:
    Contest.my_artist_invite(standard_params(conn, %{id_or_slug: id}))
  defp fetch_artist_invite(_), do: nil
end
