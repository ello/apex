defmodule Ello.V2.UserViewTest do
  use Ello.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.User
  alias Ello.V2.UserView

  test "user.json - it renders the user" do
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
      experimental_features: true,
      #relationship_priority: "self",
      bad_for_seo: false,
      is_hireable: false,
      is_collaborateable: false,
      #posts_count: 8,
      #followers_count: 31,
      #following_count: 66,
      #loves_count: 189,
      #formatted_short_bio: "<p>Backend Lead <a href='/ello' class='user-mention'>@ello</a>, but fond of cars and inspired by architecture. Finding beauty in engineering.</p>",
      # external_links_list: [
      #   %{
      #     "url" => "http://twitter.com/ArcherFX",
      #     "text" => "twitter.com/ArcherFX",
      #     "type" => "Twitter",
      #     "icon" => "https://social-icons.ello.co/twitter.png"
      #   },
      # ],
      background_position: "50% 50%",
      avatar: %{
        "original" => %{
          "url" => "https://assets.ello.co/uploads/user/avatar/42/ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png"
        },
        "large" => %{
          "url" => "https://assets.ello.co/uploads/user/avatar/42/ello-large-fad52e18.png",
          "metadata" => %{
            "size" => 220669,
            "type" => "image/png",
            "width" => 360,
            "height" => 360
          }
        },
        "regular" => %{
          "url" => "https://assets.ello.co/uploads/user/avatar/42/ello-regular-fad52e18.png",
          "metadata" => %{
            "size" => 36629,
            "type" => "image/png",
            "width" => 120,
            "height" => 120
          }
        },
        "small" => %{
          "url" => "https://assets.ello.co/uploads/user/avatar/42/ello-small-fad52e18.png",
          "metadata" => %{
            "size" => 17753,
            "type" => "image/png",
            "width" => 60,
            "height" => 60
          }
        }
      },
      cover_image: %{
        "original" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-e76606cf-44b0-48b5-9918-1efad8e0272c.jpeg"
        },
        "optimized" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
          "metadata" => %{
            "size" => 1177127,
            "type" => "image/jpeg",
            "width" => 1880,
            "height" => 1410
          }
        },
        "xhdpi" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-xhdpi-061fb4e4.jpg",
          "metadata" => %{
            "size" => 582569,
            "type" => "image/jpeg",
            "width" => 1116,
            "height" => 837
          }
        },
        "hdpi" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-hdpi-061fb4e4.jpg",
          "metadata" => %{
            "size" => 150067,
            "type" => "image/jpeg",
            "width" => 552,
            "height" => 414
          }
        },
        "mdpi" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-mdpi-061fb4e4.jpg",
          "metadata" => %{
            "size" => 40106,
            "type" => "image/jpeg",
            "width" => 276,
            "height" => 207
          }
        },
        "ldpi" => %{
          "url" => "https://assets.ello.co/uploads/user/cover_image/42/ello-ldpi-061fb4e4.jpg",
          "metadata" => %{
            "size" => 10872,
            "type" => "image/jpeg",
            "width" => 132,
            "height" => 99
          }
        }
      },
      links: %{ categories: [] }
    }
    assert render(UserView, "user.json", user: user1) == expected
  end

  def user1 do
    %User{
      id: 42,
      username: "archer",
      name: "Sterling Archer",
      bad_for_seo?: false,
      location: "New York, NY",
      background_position: "50% 50%",
      avatar: "ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png",
      avatar_metadata: %{
        "large" => %{
          "size" => 220669,
          "type" => "image/png",
          "width" => 360,
          "height" => 360
        },
        "regular" => %{
          "size" => 36629,
          "type" => "image/png",
          "width" => 120,
          "height" => 120
        },
        "small" => %{
          "size" => 17753,
          "type" => "image/png",
          "width" => 60,
          "height" => 60
        }
      },
      cover_image: "ello-e76606cf-44b0-48b5-9918-1efad8e0272c.jpeg",
      cover_image_metadata: %{
        "optimized" => %{
          "size" => 1177127,
          "type" => "image/jpeg",
          "width" => 1880,
          "height" => 1410
        },
        "xhdpi" => %{
          "size" => 582569,
          "type" => "image/jpeg",
          "width" => 1116,
          "height" => 837
        },
        "hdpi" => %{
          "size" => 150067,
          "type" => "image/jpeg",
          "width" => 552,
          "height" => 414
        },
        "mdpi" => %{
          "size" => 40106,
          "type" => "image/jpeg",
          "width" => 276,
          "height" => 207
        },
        "ldpi" => %{
          "size" => 10872,
          "type" => "image/jpeg",
          "width" => 132,
          "height" => 99
        }
      },
      settings: %User.Settings{
        views_adult_content: true,
      }
    }
  end
end
