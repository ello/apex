defmodule Ello.V2.Manage.SubmissionCountControllerTest do
  use Ello.V2.ConnCase

  setup %{conn: conn} do
    archer = Script.insert(:archer)
    brand  = Factory.insert(:user)
    staff  = Factory.insert(:user, %{is_staff: true})
    a_inv1 = Factory.insert(:artist_invite, %{status: "open"})
    a_inv2 = Factory.insert(:artist_invite, %{status: "open", brand_account: brand})
    yesterday = DateTime.utc_now()
                |> DateTime.to_unix()
                |> Kernel.-(86_400)
                |> DateTime.from_unix!()
    Factory.insert_list(2, :artist_invite_submission, %{artist_invite: a_inv1})
    Factory.insert_list(2, :artist_invite_submission, %{artist_invite: a_inv2})
    Factory.insert_list(2, :artist_invite_submission, %{
      artist_invite: a_inv2,
      post: Factory.insert(:post, %{created_at: yesterday})
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

  test "GET /api/v2/manage/artist-invites/:id/daily-submissions - staff token", %{staff_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-submissions")
    assert %{"daily_submissions" => dailys} = json_response(conn, 200)
    assert [d1, d2] = dailys
    assert d1["date"]
    assert d1["submissions"] == 2
    assert d1["type"] == "all"
    assert d1["id"]
    assert d2["date"]
    assert d2["submissions"] == 2
    assert d2["type"] == "all"
    assert d2["id"]
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-submissions - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-submissions")
    assert conn.status == 200
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-submissions - brand token - wrong invite", %{brand_conn: conn, a_inv1: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-submissions")
    assert conn.status == 404
  end

  test "GET /api/v2/manage/artist-invites/:id/daily-submissions - user token", %{conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/daily-submissions")
    assert conn.status == 404
  end
end
