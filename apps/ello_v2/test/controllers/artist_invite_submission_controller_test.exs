defmodule Ello.V2.ArtistInviteSubmissionControllerTest do
  use Ello.V2.ConnCase
  alias Ello.Core.Repo

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    brand = Factory.insert(:user)
    staff = Factory.insert(:user, is_staff: true)
    invite = Factory.insert(:artist_invite, %{
      brand_account: brand,
      status:        "open",
      slug:          "test",
    })

    declined_submission_1 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "declined", created_at: FactoryTime.now_offset(1))
    declined_submission_2 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "declined", created_at: FactoryTime.now_offset(2))
    declined_submission_3 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "declined", created_at: FactoryTime.now_offset(3))
    declined_submission_4 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "declined", created_at: FactoryTime.now_offset(4))

    unapproved_submission_1 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "unapproved", created_at: FactoryTime.now_offset(5))
    unapproved_submission_2 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "unapproved", created_at: FactoryTime.now_offset(6))
    unapproved_submission_3 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "unapproved", created_at: FactoryTime.now_offset(7))
    unapproved_submission_4 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "unapproved", created_at: FactoryTime.now_offset(8))

    approved_submission_1 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "approved", created_at: FactoryTime.now_offset(9))
    approved_submission_2 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "approved", created_at: FactoryTime.now_offset(10))
    approved_submission_3 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "approved", post: Factory.add_assets(Factory.insert(:post)), created_at: FactoryTime.now_offset(11))
    approved_submission_4 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "approved", post: Factory.add_assets(Factory.insert(:post)), created_at: FactoryTime.now_offset(12))

    selected_submission_1 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "selected", created_at: FactoryTime.now_offset(13))
    selected_submission_2 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "selected", created_at: FactoryTime.now_offset(14))
    selected_submission_3 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "selected", created_at: FactoryTime.now_offset(15))
    selected_submission_4 = Factory.insert(:artist_invite_submission, artist_invite: invite, status: "selected", created_at: FactoryTime.now_offset(16))

    declined = [declined_submission_1, declined_submission_2, declined_submission_3, declined_submission_4]
    unapproved = [unapproved_submission_1, unapproved_submission_2, unapproved_submission_3, unapproved_submission_4]
    approved = [approved_submission_1, approved_submission_2]
    approved_with_images = [approved_submission_3, approved_submission_4]
    selected = [selected_submission_1, selected_submission_2, selected_submission_3, selected_submission_4]

    {:ok, [
      conn:       public_conn(conn),
      staff_conn: auth_conn(conn, staff),
      brand_conn: auth_conn(conn, brand),
      invite:     invite,
      declined:   declined,
      unapproved: unapproved,
      approved:   approved,
      selected:   selected,
      approved_with_images: approved_with_images,
    ]}
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=submitted - regular user", %{conn: conn} do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "unapproved"})
    assert resp.status == 204
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=declined - staff user", %{staff_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "declined"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:declined], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      refute submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=submitted - staff user", %{staff_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "unapproved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      refute submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=submitted - brand user", %{brand_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "unapproved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      refute submission.id in ids
    end
  end

  test "GET /v2/artist_invtes/~:slug/submission - pagination", %{conn: conn} = c do
    c[:approved]
    |> Enum.with_index(DateTime.to_unix(DateTime.utc_now))
    |> Enum.each(fn {sub, time} ->
      {:ok, created_at} = DateTime.from_unix(time)
      {:ok, _} = Repo.update(Ecto.Changeset.change(sub, %{
        created_at: created_at
      }))
    end)
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{
      "status"   => "approved",
      "per_page" => "2",
    })
    json = json_response(resp, 200)
    assert [_, _] = json["artist_invite_submissions"]
    [link] = get_resp_header(resp, "link")
    [_, before] = Regex.run(~r/before=([^&]*)&/, link)
    resp2 = get(conn, "/api/v2/artist_invites/~test/submissions", %{
      "status"   => "approved",
      "per_page" => "2",
      "before"   => before,
    })
    json2 = json_response(resp2, 200)
    assert [_, _] = json2["artist_invite_submissions"]
    refute json2 == json
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=approved - regular user - invite open", %{conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "approved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=approved - submissions are in descending order", %{conn: conn} = c do
    {:ok, _} = Repo.update(Ecto.Changeset.change(c[:invite], status: "closed"))
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "approved"})
    json = json_response(resp, 200)
    # require IEx; IEx.pry
    [sub1, sub2, sub3, sub4] = json["artist_invite_submissions"]
    {:ok, date1, _} = DateTime.from_iso8601(sub1["created_at"])
    {:ok, date2, _} = DateTime.from_iso8601(sub2["created_at"])
    {:ok, date3, _} = DateTime.from_iso8601(sub3["created_at"])
    {:ok, date4, _} = DateTime.from_iso8601(sub4["created_at"])
    assert date1 > date2
    assert date2 > date3
    assert date3 > date4
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=approved - regular user - invite closed", %{conn: conn} = c do
    {:ok, _} = Repo.update(Ecto.Changeset.change(c[:invite], status: "closed"))
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "approved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      refute submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=approved - staff user", %{staff_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "approved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=approved - brand user", %{brand_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "approved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      assert submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=selected - regular user - invite open", %{conn: conn} do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "selected"})
    assert resp.status == 204
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=selected - regular user - invite closed", %{conn: conn} = c do
    {:ok, _} = Repo.update(Ecto.Changeset.change(c[:invite], status: "closed"))
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "selected"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=selected - staff user", %{staff_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "selected"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=selected - brand user", %{brand_conn: conn} = c do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "selected"})
    json = json_response(resp, 200)
    ids = Enum.map(json["artist_invite_submissions"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      refute submission.id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end

  test "GET /v2/artist_invites/~:slug/submission_posts?status=approved - as posts - regular user - invite closed", %{conn: conn} = c do
    {:ok, _} = Repo.update(Ecto.Changeset.change(c[:invite], status: "closed"))
    resp = get(conn, "/api/v2/artist_invites/~test/submission_posts", %{"status" => "approved"})
    json = json_response(resp, 200)
    ids = Enum.map(json["posts"], &String.to_integer(&1["id"]))
    Enum.each c[:unapproved], fn(submission) ->
      refute submission.post_id in ids
    end
    Enum.each c[:approved], fn(submission) ->
      assert submission.post_id in ids
    end
    Enum.each c[:approved_with_images], fn(submission) ->
      assert submission.post_id in ids
    end
    Enum.each c[:selected], fn(submission) ->
      refute submission.post_id in ids
    end
  end
end
