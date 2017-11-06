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
      post: Factory.insert(:post, %{
        created_at: yesterday,
        author: Factory.insert(:user, %{category_ids: [1, 2]})
      }),
      status: "approved",
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
    assert d1["id"]
    assert d1["artist_invite_id"]
    assert d1["date"]
    assert d1["submissions"] == 2
    assert d1["status"] == "all"
    assert d2["id"]
    assert d2["artist_invite_id"]
    assert d2["date"]
    assert d2["submissions"] == 2
    assert d2["status"] == "all"
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

  test "GET /api/v2/manage/artist-invites/:id/total-submissions - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/total-submissions")
    assert %{"total_submissions" => totals} = json_response(conn, 200)
    assert [t1, t2] = totals
    assert t1["id"]
    assert t1["artist_invite_id"]
    assert t1["submissions"] == 2
    assert t1["status"] in ["Approved", "Unapproved"]
    assert t2["id"]
    assert t2["artist_invite_id"]
    assert t2["submissions"] == 2
    assert t2["status"] in ["Approved", "Unapproved"]
  end

  test "GET /api/v2/manage/artist-invites/:id/total-participants - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/total-participants")
    assert %{"total_participants" => totals} = json_response(conn, 200)
    assert [p1, p2] = totals
    assert p1["id"]
    assert p1["artist_invite_id"]
    assert p1["participants"] == 2
    assert p1["type"] in ["Influencer", "Normal"]
    assert p2["id"]
    assert p2["artist_invite_id"]
    assert p2["participants"] == 2
    assert p2["type"] in ["Influencer", "Normal"]
  end
end
