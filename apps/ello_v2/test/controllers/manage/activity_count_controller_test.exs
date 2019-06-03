defmodule Ello.V2.Manage.ActivityCountControllerTest do
  use Ello.V2.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    archer = Script.insert(:archer)
    brand  = Factory.insert(:user, username: "yolo")
    staff  = Factory.insert(:user, %{is_staff: true})
    a_inv1 = Factory.insert(:artist_invite, %{status: "open"})
    a_inv2 = Factory.insert(:artist_invite, %{status: "open", brand_account: brand})
    later_created_at = FactoryTime.now_offset(1)
    post1 = Factory.insert(:post, created_at: later_created_at)
    _sub1 = Factory.insert(:artist_invite_submission, post: post1, artist_invite: a_inv2)
    _comment1 = Factory.insert(:post, parent_post: post1, created_at: later_created_at)
    _love1 = Factory.insert(:love, post: post1)
    repost1 = Factory.insert(:post, reposted_source: post1, created_at: later_created_at)
    _repost_comment1 = Factory.insert(:post, parent_post: repost1, created_at: later_created_at)
    _repost_love1 = Factory.insert(:love, post: repost1)
    _mention1 = Factory.insert(:post, mentioned_usernames: ["yolo"], created_at: later_created_at)
    _follower1 = Factory.insert(:relationship, subject: brand, priority: "friend", created_at: later_created_at)
    _following1 = Factory.insert(:relationship, owner: brand, priority: "friend", created_at: later_created_at)
    _blocked1 = Factory.insert(:relationship, subject: brand, priority: "block", created_at: later_created_at)

    {:ok,
      unauth_conn: conn,
      conn: auth_conn(conn, archer),
      staff_conn: auth_conn(conn, staff),
      brand_conn: auth_conn(conn, brand),
      a_inv1: a_inv1,
      a_inv2: a_inv2,
    }
  end

  test "GET /api/v2/manage/artist-invites/:id/total-activities - brand token", %{brand_conn: conn, a_inv2: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/total-activities")
    assert %{"total_activities" => activities} = json_response(conn, 200)
    assert [comments, loves, reposts, followers, mentions | _] = activities
    assert comments["type"] == "comments"
    assert comments["artist_invite_id"]
    assert comments["id"]
    assert comments["activities"] == 2
    assert loves["type"] == "loves"
    assert loves["artist_invite_id"]
    assert loves["id"]
    assert loves["activities"] == 2
    assert reposts["type"] == "reposts"
    assert reposts["artist_invite_id"]
    assert reposts["id"]
    assert reposts["activities"] == 1
    assert mentions["type"] == "mentions"
    assert mentions["artist_invite_id"]
    assert mentions["id"]
    assert mentions["activities"] == 1
    assert followers["type"] == "followers"
    assert followers["artist_invite_id"]
    assert followers["id"]
    assert followers["activities"] == 1
  end

  test "GET /api/v2/manage/artist-invites/:id/total-activities - brand token - wrong invite", %{brand_conn: conn, a_inv1: invite} do
    conn = get(conn, "/api/v2/manage/artist-invites/#{invite.id}/total-activities")
    assert conn.status == 404
  end
end
