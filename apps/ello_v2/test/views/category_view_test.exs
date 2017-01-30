defmodule Ello.V2.CategoryViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.CategoryView

  setup %{conn: conn} do
    cat1 = Script.insert(:espionage_category, header: "Spy Shit")
    cat2 = Script.insert(:lacross_category)
    {:ok, conn: conn, cat1: cat1, cat2: cat2}
  end

  test "index.json - renders each category, promo, and user", context do
    assert %{
      categories: [_, _],
      linked: %{
        promotionals: [_],
        users: [_],
      }
    } = render(CategoryView, "index.json",
      categories: [context.cat1, context.cat2],
      conn: context.conn
    )
  end

  test "show.json - renders category, promos and users", context do
    assert %{
      categories: %{},
      linked: %{
        promotionals: [_],
        users: [_],
      }
    } = render(CategoryView, "show.json",
      category: context.cat2,
      conn: context.conn
    )
  end

  test "category.json - default image", context do
    expected = %{
      id: "#{context.cat1.id}",
      name: "Espionage",
      slug: "espionage",
      cta_caption: nil,
      cta_href: nil,
      description: "All things spying related",
      is_sponsored: false,
      level: nil,
      order: 0,
      uses_page_promotionals: false,
      allow_in_onboarding: false,
      header: "Spy Shit",
      links: %{
        promotionals: [],
        recent: %{related: "/api/v2/categories/espionage/posts/recent"}
      },
      tile_image: %{
        "original" => %{
          url: "https://assets.ello.co/images/fallback/category/tile_image/ello-default.png",
        },
        "large" => %{
          url: "https://assets.ello.co/images/fallback/category/tile_image/ello-default-large.png",
          metadata: nil,
        },
        "regular" => %{
          url: "https://assets.ello.co/images/fallback/category/tile_image/ello-default-regular.png",
          metadata: nil,
        },
        "small" => %{
          url: "https://assets.ello.co/images/fallback/category/tile_image/ello-default-small.png",
          metadata: nil,
        },
      }
    }
    assert render(CategoryView, "category.json",
      category: context.cat1,
      conn: context.conn
    ) == expected
  end

  test "category.json - with image", context do
    expected = %{
      id: "#{context.cat2.id}",
      name: "Lacross",
      slug: "lacross",
      cta_caption: nil,
      cta_href: nil,
      description: "All things lacross related",
      is_sponsored: false,
      level: "Primary",
      order: 0,
      uses_page_promotionals: false,
      allow_in_onboarding: false,
      header: "Lacross",
      links: %{
        promotionals: Enum.map(context.cat2.promotionals, &("#{&1.id}")),
        recent: %{related: "/api/v2/categories/lacross/posts/recent"}
      },
      tile_image: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/#{context.cat2.id}/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/#{context.cat2.id}/ello-large-23cb59fe.png",
          metadata: %{
            size:   855_144,
            type:   "image/png",
            width:  1000,
            height: 1000
          }
        },
        "regular" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/#{context.cat2.id}/ello-regular-23cb59fe.png",
          metadata: %{
            size:   556_821,
            type:   "image/png",
            width:  800,
            height: 800
          }
        },
        "small" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/#{context.cat2.id}/ello-small-23cb59fe.png",
          metadata: %{
            size:   126_225,
            type:   "image/png",
            width:  360,
            height: 360
          }
        }
      }
    }
    assert render(CategoryView, "category.json",
      category: context.cat2,
      conn: context.conn
    ) == expected
  end
end
