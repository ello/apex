defmodule Ello.V2.Manage.ArtistInviteControllerTest do
  use Ello.V2.ConnCase, async: false

  setup %{conn: conn} do
    archer = Script.insert(:archer)
    brand  = Factory.insert(:user)
    staff  = Factory.insert(:user, %{is_staff: true})
    a_inv1 = Factory.insert(:artist_invite, %{status: "open"})
    a_inv2 = Factory.insert(:artist_invite, %{status: "open", brand_account: brand})
    {:ok,
      unauth_conn: conn,
      conn: auth_conn(conn, archer),
      staff_conn: auth_conn(conn, staff),
      brand_conn: auth_conn(conn, brand),
      a_inv1: a_inv1,
      a_inv2: a_inv2,
    }
  end

  test "GET /v2/artist_invites - staff token", %{staff_conn: conn} do
    conn = get(conn, manage_artist_invite_path(conn, :index))
    assert conn.status == 200
  end

  test "GET /v2/artist_invites - brand token", %{brand_conn: conn} do
    conn = get(conn, manage_artist_invite_path(conn, :index))
    assert conn.status == 200
  end

  test "GET /v2/manage/artist_invites - public token", %{unauth_conn: conn} do
    conn = conn
           |> public_conn
           |> get(manage_artist_invite_path(conn, :index))
    assert conn.status == 401
  end

  @tag :json_schema
  test "GET /v2/manage/artist_invites - json schema", %{staff_conn: conn} do
    conn = get(conn, manage_artist_invite_path(conn, :index))
    json_response(conn, 200)
    assert :ok = validate_json("artist_invite", json_response(conn, 200))
  end
end
