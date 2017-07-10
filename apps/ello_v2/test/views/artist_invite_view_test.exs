defmodule Ello.V2.ArtistInviteViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.ArtistInviteView
  alias Ello.Core.Contest.ArtistInvite

  setup %{conn: conn} do
    a_inv1 = Factory.insert(:artist_invite) |> ArtistInvite.load_images
    a_inv2 = Factory.insert(:artist_invite) |> ArtistInvite.load_images
    {:ok, conn: conn, a_inv1: a_inv1, a_inv2: a_inv2}
  end

  test "index.json - renders each artist invite and brand account", context do
    assert %{
      artist_invites: [_, _],
      linked: %{
        users: [_, _],
      }
    } = render(ArtistInviteView, "index.json",
      data: [context.a_inv1, context.a_inv2],
      conn: context.conn
    )
  end

  test "artist_invite.json - with images", context do
    id = "#{context.a_inv2.id}"
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
end
