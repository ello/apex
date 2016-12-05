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
            tile_image: "TODO",
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
            tile_image: "TODO",
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
    }
  end
end
