defmodule Ello.V2.CategoryViewTest do
  use Ello.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.Category
  alias Ello.V2.CategoryView

  test "renders index.json" do
    assert render(CategoryView, "index.json", %{categories: [cat1, cat2]}) ==
      %{
        categories: [
          %{
            id: "1",
            name: "Design",
            slug: "design",
            cta_caption: nil,
            cta_href: nil,
            description: "All thing design related",
            is_sponsored: false,
            level: nil,
            order: 0,
            uses_page_promotionals: false,
            header: nil,
            links: %{
              promotionals: ["TODO"],
              recent: %{related: "/api/v2/categories/design/posts/recent"}
            },
            tile_image: %{
              "original" => %{
                "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default.png",
              },
              "large" => %{
                "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-large.png",
                "metadata" => nil,
              },
              "regular" => %{
                "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-regular.png",
                "metadata" => nil,
              },
              "small" => %{
                "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-small.png",
                "metadata" => nil,
              },
            },
          },
          %{
            id: "2",
            name: "Development",
            slug: "development",
            cta_caption: nil,
            cta_href: nil,
            description: "All thing dev related",
            is_sponsored: false,
            level: "Primary",
            order: 0,
            uses_page_promotionals: false,
            header: nil,
            links: %{
              promotionals: ["TODO"],
              recent: %{related: "/api/v2/categories/development/posts/recent"}
            },
            tile_image: %{
              "original" => %{
                "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-optimized-8bcedb76.jpg"
              },
              "large" => %{
                "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-large-23cb59fe.png",
                "metadata" => %{
                  "size"   => 855144,
                  "type"   => "image/png",
                  "width"  => 1000,
                  "height" => 1000
                }
              },
              "regular" => %{
                "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-regular-23cb59fe.png",
                "metadata" => %{
                  "size"   => 556821,
                  "type"   => "image/png",
                  "width"  => 800,
                  "height" => 800
                }
              },
              "small" => %{
                "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-small-23cb59fe.png",
                "metadata" => %{
                  "size"   => 126225,
                  "type"   => "image/png",
                  "width"  => 360,
                  "height" => 360
                }
              }
            }
          }
        ]
      }
  end


  defp cat1 do
    %Category{
      id: 1,
      name: "Design",
      slug: "design",
      cta_caption: nil,
      cta_href: nil,
      description: "All thing design related",
      is_sponsored: false,
      level: nil,
      order: 0,
      uses_page_promotionals: false,
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
    }
  end

  defp cat2 do
    %Category{
      id: 2,
      name: "Development",
      slug: "development",
      cta_caption: nil,
      cta_href: nil,
      description: "All thing dev related",
      is_sponsored: false,
      level: "Primary",
      order: 0,
      uses_page_promotionals: false,
      created_at: Ecto.DateTime.utc,
      updated_at: Ecto.DateTime.utc,
      tile_image: "ello-optimized-8bcedb76.jpg",
      tile_image_metadata: %{
        "large" => %{
          "size"   => 855144,
          "type"   => "image/png",
          "width"  => 1000,
          "height" => 1000
        },
        "regular" => %{
          "size"   => 556821,
          "type"   => "image/png",
          "width"  => 800,
          "height" => 800
        },
        "small" => %{
          "size"   => 126225,
          "type"   => "image/png",
          "width"  => 360,
          "height" => 360
        },
      },
    }
  end
end
