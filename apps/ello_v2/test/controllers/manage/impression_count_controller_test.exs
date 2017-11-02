defmodule Ello.V2.Manage.ImpressionCountControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Grandstand

  setup %{conn: conn} do
    archer = Script.insert(:archer)
    brand  = Factory.insert(:user)
    staff  = Factory.insert(:user, %{is_staff: true})
    a_inv1 = Factory.insert(:artist_invite, %{status: "open"})
    a_inv2 = Factory.insert(:artist_invite, %{status: "open", brand_account: brand})
    today = DateTime.utc_now()
            |> Timex.format!("{YYYY}-{M}-{D}")
    tomorrow = DateTime.utc_now()
               |> DateTime.to_unix()
               |> Kernel.+(86_400)
               |> DateTime.from_unix!()
               |> Timex.format!("{YYYY}-{M}-{D}")
    Grandstand.Client.Test.start
    Grandstand.Client.Test.reset
    Grandstand.Client.Test.add(%{
      impressions: 100,
      artist_invite_id: "#{a_inv2.id}",
      stream_kind: nil,
      date: today,
    })
    Grandstand.Client.Test.add(%{
      impressions: 103,
      artist_invite_id: "#{a_inv2.id}",
      stream_kind: nil,
      date: tomorrow,
    })
    {:ok,
      unauth_conn: conn,
      conn: auth_conn(conn, archer),
      staff_conn: auth_conn(conn, staff),
      brand_conn: auth_conn(conn, brand),
      a_inv1: a_inv1,
      a_inv2: a_inv2,
    }
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-impressions - staff token", %{staff_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-impressions")
    assert %{"daily_impressions" => [d1, d2]} = json_response(conn, 200)
    assert d1["date"]
    assert d1["id"]
    assert d1["impressions"] == 103
    assert d1["artist_invite_id"] == "#{invite.id}"
    assert d2["date"]
    assert d2["id"]
    assert d2["impressions"] == 100
    assert d2["artist_invite_id"] == "#{invite.id}"
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-impressions - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-impressions")
    assert conn.status == 200
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-impressions - brand token - wrong invite", %{brand_conn: conn, a_inv1: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-impressions")
    assert conn.status == 404
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-impressions - user token", %{conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-impressions")
    assert conn.status == 404
  end

  test "GET /api/v2/manage/artist-invites/:id/total-impressions - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/total-impressions")
    assert %{"total_impressions" => [t1]} = json_response(conn, 200)
    assert t1["id"]
    assert t1["impressions"] == 203
    assert t1["artist_invite_id"] == "#{invite.id}"
  end
end
