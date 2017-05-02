defmodule Ello.V2.UserViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.UserView

  setup %{conn: conn} do
    spying = Script.insert(:espionage_category)
    archer = Script.build(:archer, categories: [spying], total_views_count: 2500)
    user = Factory.build(:user, %{
      id: 1234,
      relationship_to_current_user: Factory.build(:relationship,
                                                  owner: archer,
                                                  priority: "friend"),
    })
    {:ok, [
        conn: user_conn(conn, archer),
        archer: archer,
        user: user,
        spying: spying,
    ]}
  end

  test "show.json - it renders the user and categories", context do
    archer_id = "#{context.archer.id}"
    spying_id = "#{context.spying.id}"
    assert %{
      users: %{
        id: ^archer_id,
        meta_attributes: %{
          description: "I have been spying for a while now",
          image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
          robots: "index, follow",
          title: "Sterling Archer (@archer) | Ello"
        },
      },
      linked: %{
        categories: [%{id: ^spying_id}],
      }
    } = render(UserView, "show.json",
      data: context.archer,
      conn: context.conn
    )
  end

  test "user.json - it renders the user", %{conn: conn, archer: archer, spying: spying} do
    expected = %{
      id: "42",
      href: "/api/v2/users/42",
      username: "archer",
      name: "Sterling Archer",
      location: "New York, NY",
      posts_adult_content: false,
      views_adult_content: true,
      has_commenting_enabled: true,
      has_sharing_enabled: true,
      has_reposting_enabled: true,
      has_loves_enabled: true,
      has_auto_watch_enabled: true,
      experimental_features: false,
      relationship_priority: "self",
      bad_for_seo: false,
      is_hireable: false,
      is_collaborateable: false,
      is_community: false,
      posts_count: nil,
      followers_count: nil,
      following_count: nil,
      loves_count: nil,
      total_views_count: 2500,
      formatted_short_bio: "<p>I have been spying for a while now</p>",
      badges: [],
      external_links_list: [
        %{
          "url" => "http://www.twitter.com/ArcherFX",
          "text" => "twitter.com/ArcherFX",
          "type" => "Twitter",
          "icon" => "https://social-icons.ello.co/twitter.png"
        },
      ],
      avatar: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/user/avatar/42/ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png"
        },
        "large" => %{
          url: "https://assets.ello.co/uploads/user/avatar/42/ello-large-fad52e18.png",
          metadata: %{
            size: 220_669,
            type: "image/png",
            width: 360,
            height: 360
          }
        },
        "regular" => %{
          url: "https://assets.ello.co/uploads/user/avatar/42/ello-regular-fad52e18.png",
          metadata: %{
            size: 36_629,
            type: "image/png",
            width: 120,
            height: 120
          }
        },
        "small" => %{
          url: "https://assets.ello.co/uploads/user/avatar/42/ello-small-fad52e18.png",
          metadata: %{
            size: 17_753,
            type: "image/png",
            width: 60,
            height: 60
          }
        }
      },
      cover_image: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-e76606cf-44b0-48b5-9918-1efad8e0272c.jpeg"
        },
        "optimized" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
          metadata: %{
            size: 1_177_127,
            type: "image/jpeg",
            width: 1880,
            height: 1410
          }
        },
        "xhdpi" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-xhdpi-061fb4e4.jpg",
          metadata: %{
            size: 582_569,
            type: "image/jpeg",
            width: 1116,
            height: 837
          }
        },
        "hdpi" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-hdpi-061fb4e4.jpg",
          metadata: %{
            size: 150_067,
            type: "image/jpeg",
            width: 552,
            height: 414
          }
        },
        "mdpi" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-mdpi-061fb4e4.jpg",
          metadata: %{
            size: 40_106,
            type: "image/jpeg",
            width: 276,
            height: 207
          }
        },
        "ldpi" => %{
          url: "https://assets.ello.co/uploads/user/cover_image/42/ello-ldpi-061fb4e4.jpg",
          metadata: %{
            size: 10_872,
            type: "image/jpeg",
            width: 132,
            height: 99
          }
        }
      },
      links: %{categories: ["#{spying.id}"]}
    }
    assert render(UserView, "user.json", user: archer, conn: conn) == expected
  end

  test "user.json - renders most badges for normal accounts", %{conn: conn, user: user} do
    user = Map.merge(user, %{badges: ["community", "nsfw", "spam"]})
    assert render(UserView, "user.json", user: user, conn: conn).badges == ["community"]
  end

  test "user.json - renders all badges for staff accounts", %{conn: conn, user: user} do
    staff = Factory.build(:user, is_staff: true)
    user = Map.merge(user, %{badges: ["community", "nsfw", "spam"]})
    conn = user_conn(conn, staff)
    assert render(UserView, "user.json", user: user, conn: conn).badges == ["community", "nsfw", "spam"]
  end

  test "user.json - knows user relationship", %{conn: conn, user: user} do
    assert render(UserView, "user.json", user: user, conn: conn).relationship_priority == "friend"
  end

  test "user.json - renders nil for total_post_views attribute for users with 0 views", %{conn: conn} do
    user = Factory.build(:user, is_system_user: true, total_views_count: 0)
    assert render(UserView, "user.json", user: user, conn: conn).total_views_count == nil
  end
end
