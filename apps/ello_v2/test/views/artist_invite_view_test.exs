defmodule Ello.V2.ArtistInviteViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.ArtistInviteView

  setup %{conn: conn} do
    a_inv1 = Factory.insert(:artist_invite)
    a_inv2 = Factory.insert(:artist_invite)
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
    expected = %{
      id: "#{context.a_inv2.id}",
      title: "#{context.a_inv2.title}",
      slug: "#{context.a_inv2.slug}",
      invite_type: "#{context.a_inv2.invite_type}",
      opened_at: context.a_inv2.opened_at,
      closed_at: context.a_inv2.closed_at,
      status: "#{context.a_inv2.status}",
      description: context.a_inv2.rendered_description,
      short_description: "#{context.a_inv2.short_description}",
      submission_body_block: "#{context.a_inv2.submission_body_block}",
      guide: context.a_inv2.guide,
      links: %{},
      header_image: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/artist_invite/header_image/#{context.a_inv2.id}/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          url: "https://assets.ello.co/uploads/artist_invite/header_image/#{context.a_inv2.id}/ello-large-23cb59fe.png",
          metadata: %{
            size:   855_144,
            type:   "image/png",
            width:  1000,
            height: 1000
          }
        },
        "regular" => %{
          url: "https://assets.ello.co/uploads/artist_invite/header_image/#{context.a_inv2.id}/ello-regular-23cb59fe.png",
          metadata: %{
            size:   556_821,
            type:   "image/png",
            width:  800,
            height: 800
          }
        },
        "small" => %{
          url: "https://assets.ello.co/uploads/artist_invite/header_image/#{context.a_inv2.id}/ello-small-23cb59fe.png",
          metadata: %{
            size:   126_225,
            type:   "image/png",
            width:  360,
            height: 360
          }
        }
      },
      logo_image: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/artist_invite/logo_image/#{context.a_inv2.id}/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          url: "https://assets.ello.co/uploads/artist_invite/logo_image/#{context.a_inv2.id}/ello-large-23cb59fe.png",
          metadata: %{
            size:   855_144,
            type:   "image/png",
            width:  1000,
            height: 1000
          }
        },
        "regular" => %{
          url: "https://assets.ello.co/uploads/artist_invite/logo_image/#{context.a_inv2.id}/ello-regular-23cb59fe.png",
          metadata: %{
            size:   556_821,
            type:   "image/png",
            width:  800,
            height: 800
          }
        },
        "small" => %{
          url: "https://assets.ello.co/uploads/artist_invite/logo_image/#{context.a_inv2.id}/ello-small-23cb59fe.png",
          metadata: %{
            size:   126_225,
            type:   "image/png",
            width:  360,
            height: 360
          }
        }
      },
    }
    assert render(ArtistInviteView, "artist_invite.json",
                  artist_invite: context.a_inv2,
                  conn: context.conn
    ) == expected
  end
end
