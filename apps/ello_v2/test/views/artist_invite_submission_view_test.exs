defmodule Ello.V2.ViewTest do
  use Ello.V2.ConnCase, async: true
  alias Ello.V2.ArtistInviteSubmissionView, as: View

  setup %{conn: conn} do
    brand = Factory.build(:user)
    staff = Factory.build(:user, is_staff: true)
    invite = Factory.build(:artist_invite, %{
      brand_account: brand,
      status:        "open",
      slug:          "test",
    })
    unapproved = Factory.build(:artist_invite_submission, %{
      artist_invite: invite,
      status:        "unapproved",
    })
    approved = Factory.build(:artist_invite_submission, %{
      artist_invite: invite,
      status:        "approved",
    })
    selected = Factory.build(:artist_invite_submission, %{
      artist_invite: invite,
      status:        "selected",
    })
    {:ok, [
      conn:       public_conn(conn),
      staff_conn: user_conn(conn, staff),
      brand_conn: user_conn(conn, brand),
      invite:     invite,
      unapproved: unapproved,
      approved:   approved,
      selected:   selected,
    ]}
  end

  test "artist_invite_sumbission.json - public user", context do
    json = View.render("artist_invite_submission.json", %{
      artist_invite_submission: context[:approved],
      conn:                     context[:conn],
    })
    refute json[:status]
    refute json[:actions]
    assert json[:links][:post][:id]
  end

  test "artist_invite_sumbission.json - staff user - unapproved", context do
    json = View.render("artist_invite_submission.json", %{
      artist_invite_submission: context[:unapproved],
      conn:                     context[:staff_conn],
    })
    assert json[:status] == "unapproved"
    assert json[:links][:post][:id]
    assert json[:actions][:approve] == %{
      label:  "Approve",
      href:   "/api/v2/artist_invite_submissions/#{context[:unapproved].id}/approve",
      method: "PUT",
      body:   %{status: "approved"},
    }
  end

  test "artist_invite_sumbission.json - staff user - approved", context do
    json = View.render("artist_invite_submission.json", %{
      artist_invite_submission: context[:approved],
      conn:                     context[:staff_conn],
    })
    assert json[:status] == "approved"
    assert json[:links][:post][:id]
    assert json[:actions][:unapprove] == %{
      label:  "Approved",
      href:   "/api/v2/artist_invite_submissions/#{context[:unapproved].id}/unapprove",
      method: "PUT",
      body:   %{status: "unapproved"},
    }
    assert json[:actions][:select] == %{
      label:  "Select",
      href:   "/api/v2/artist_invite_submissions/#{context[:unapproved].id}/select",
      method: "PUT",
      body:   %{status: "selected"},
    }
  end

  test "artist_invite_sumbission.json - staff user - selected", context do
    json = View.render("artist_invite_submission.json", %{
      artist_invite_submission: context[:selected],
      conn:                     context[:staff_conn],
    })
    assert json[:status] == "selected"
    assert json[:links][:post][:id]
    assert json[:actions][:unselect] == %{
      label:  "Selected",
      href:   "/api/v2/artist_invite_submissions/#{context[:selected].id}/deselect",
      method: "PUT",
      body:   %{status: "approved"},
    }
  end
end

