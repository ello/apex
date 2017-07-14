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
    unapproved = Factory.insert_list(4, :artist_invite_submission, %{
      artist_invite: invite,
      status:        "unapproved",
    })
    approved = Factory.insert_list(4, :artist_invite_submission, %{
      artist_invite: invite,
      status:        "approved",
    })
    selected = Factory.insert_list(4, :artist_invite_submission, %{
      artist_invite: invite,
      status:        "selected",
    })
    {:ok, [
      conn:       public_conn(conn),
      staff_conn: auth_conn(conn, staff),
      brand_conn: auth_conn(conn, brand),
      invite:     invite,
      unapproved: unapproved,
      approved:   approved,
      selected:   selected,
    ]}
  end

  test "GET /v2/artist_invites/~:slug/submissions?status=submitted - regular user", %{conn: conn} do
    resp = get(conn, "/api/v2/artist_invites/~test/submissions", %{"status" => "unapproved"})
    assert resp.status == 204
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
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
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
    Enum.each c[:selected], fn(submission) ->
      assert submission.id in ids
    end
  end
end
