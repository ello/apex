defmodule Ello.V2.ArtistInviteControllerTest do
  use Ello.V2.ConnCase, async: false

  setup %{conn: conn} do
    Factory.insert(:artist_invite)
    {:ok, unauth_conn: conn}
  end

  test "GET /v2/artist_invites - public token", %{unauth_conn: conn} do
    conn = conn
           |> public_conn
           |> get(artist_invite_path(conn, :index))
    assert conn.status == 200
  end
end
