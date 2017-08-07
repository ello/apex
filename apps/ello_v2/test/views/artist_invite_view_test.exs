defmodule Ello.V2.ArtistInviteViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.ArtistInviteView
  alias Ello.Core.Contest.ArtistInvite

  setup %{conn: conn} do
    brand = Factory.insert(:user)
    staff = Factory.insert(:user, is_staff: true)
    a_inv1 = ArtistInvite.load_images(Factory.insert(:artist_invite, %{
      status:        "open",
      brand_account: brand,
    }))
    a_inv2 = ArtistInvite.load_images(Factory.insert(:artist_invite, %{
      status:        "closed",
      brand_account: brand,
    }))
    {:ok, [
      conn:       conn,
      staff_conn: user_conn(conn, staff),
      brand_conn: user_conn(conn, brand),
      a_inv1:     a_inv1,
      a_inv2:     a_inv2,
    ]}
  end

  test "index.json - renders each artist invite", context do
    assert %{
      artist_invites: [_, _]
    } = render(ArtistInviteView, "index.json",
      data: [context.a_inv1, context.a_inv2],
      conn: context.conn
    )
  end

  test "artist_invite.json - with images", context do
    assert %{
      id: _,
      title: _,
      slug: _,
      invite_type: _,
      opened_at: _,
      closed_at: _,
      status: _,
      description: _,
      short_description: _,
      submission_body_block: _,
      guide: _,
      links: _,
      header_image: %{
        "original" => %{},
        "optimized" => %{},
        "xhdpi" => %{},
        "mdpi" => %{},
        "ldpi" => %{},
      },
      logo_image: %{
        "original" => %{},
        "optimized" => %{},
        "xhdpi" => %{},
        "mdpi" => %{},
        "ldpi" => %{},
      },
    } = render(ArtistInviteView, "artist_invite.json",
                  artist_invite: context.a_inv2,
                  conn: context.conn
    )
  end

  test "artist_invite.json - links - open - as public", context do
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: context.a_inv1,
      conn:          context.conn,
    })

    refute json[:links][:unapproved_submissions]
    refute json[:links][:selected_submissions]

    assert json[:links][:approved_submissions][:type] == "artist_invite_submission_stream"
    assert json[:links][:approved_submissions][:href] =~ ~r"/api/v2/artist_invites/\d*/submissions\?status=approved"
  end

  test "artist_invite.json - links - closed - as public", context do
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: context.a_inv2,
      conn:          context.conn,
    })

    refute json[:links][:unapproved_submissions]

    assert json[:links][:approved_submissions][:type] == "artist_invite_submission_stream"
    assert json[:links][:approved_submissions][:href] =~ ~r"/api/v2/artist_invites/\d*/submissions\?status=approved"

    assert json[:links][:selected_submissions][:type] == "artist_invite_submission_stream"
    assert json[:links][:selected_submissions][:href] =~ ~r"/api/v2/artist_invites/\d*/submissions\?status=selected"
  end

  test "artist_invite.json - links - as staff", context do
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: context.a_inv1,
      conn:          context.staff_conn,
    })

    assert json[:links][:unapproved_submissions][:type] == "artist_invite_submission_stream"
    assert json[:links][:unapproved_submissions][:href] =~ ~r"/api/v2/artist_invites/\d*/submissions\?status=unapproved"

    assert json[:links][:approved_submissions]
    assert json[:links][:selected_submissions]
  end


  test "artist_invite.json - links - as brand", context do
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: context.a_inv1,
      conn:          context.brand_conn,
    })

    assert json[:links][:unapproved_submissions]
    assert json[:links][:approved_submissions]
    assert json[:links][:selected_submissions]
  end

  test "artist_invit.json - status - preview", context do
    inv = %{context.a_inv1 | status: "preview"}
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: inv,
      conn:          context.brand_conn,
    })
    assert json[:status] == "preview"
  end

  test "artist_invit.json - status - upcoming", context do
    now = DateTime.utc_now |> DateTime.to_unix
    inv = %{context.a_inv1 |
      status: "open",
      opened_at: DateTime.from_unix!(now + 1_000_000),
      closed_at: DateTime.from_unix!(now + 2_000_000),
    }
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: inv,
      conn:          context.conn,
    })
    assert json[:status] == "upcoming"
  end

  test "artist_invit.json - status - open", context do
    now = DateTime.utc_now |> DateTime.to_unix
    inv = %{context.a_inv1 |
      status:    "open",
      opened_at: DateTime.from_unix!(now - 1_000_000),
      closed_at: DateTime.from_unix!(now + 1_000_000),
    }
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: inv,
      conn:          context.conn,
    })
    assert json[:status] == "open"
  end

  test "artist_invit.json - status - selecting", context do
    now = DateTime.utc_now |> DateTime.to_unix
    inv = %{context.a_inv1 |
      status:    "open",
      opened_at: DateTime.from_unix!(now - 2_000_000),
      closed_at: DateTime.from_unix!(now - 1_000_000),
    }
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: inv,
      conn:          context.conn,
    })
    assert json[:status] == "selecting"
  end

  test "artist_invit.json - status - closed", context do
    inv = %{context.a_inv1 | status: "closed"}
    json = ArtistInviteView.render("artist_invite.json", %{
      artist_invite: inv,
      conn:          context.conn,
    })
    assert json[:status] == "closed"
  end
end
