defmodule Ello.V2.ArtistInviteControllerTest do
  use Ello.V2.ConnCase, async: false

  setup %{conn: conn} do
    archer = Script.insert(:archer)
    a_inv1 = Factory.insert(:artist_invite)
    Factory.insert(:artist_invite)
    {:ok, unauth_conn: conn, conn: auth_conn(conn, archer), a_inv1: a_inv1}
  end

  test "GET /v2/artist_invites - public token", %{unauth_conn: conn} do
    conn = conn
           |> public_conn
           |> get(artist_invite_path(conn, :index))
    assert conn.status == 200
  end

  test "GET /v2/artist_invites - user token", %{conn: conn} do
    conn = get(conn, artist_invite_path(conn, :index))
    assert conn.status == 200
  end

  test "GET /v2/artist_invites/:slug - public token with slug", %{unauth_conn: conn, a_inv1: a_inv1} do
    conn = conn
           |> public_conn
           |> get(artist_invite_path(conn, :show, a_inv1.slug))
    assert conn.status == 200
  end

  test "GET /v2/artist_invites/:id - public token with id", %{unauth_conn: conn, a_inv1: a_inv1} do
    conn = conn
           |> public_conn
           |> get(artist_invite_path(conn, :show, a_inv1.id))
    assert conn.status == 200
  end

  # test "GET /v2/artist_invites/:slug - user token", %{conn: conn} do
  #   conn = get(conn, artist_invite_path(conn, :index))
  #   assert conn.status == 200
  # end

# Preview Flag
#
#   test "GET /v2/artist_invites - ", %{conn: conn} do
#     conn = get(conn, artist_invite_path(conn, :index))
#     response = json_response(conn, 200)
#     IO.inspect(response)
#     # assert response.status == 200
#   end
end
