defmodule Ello.V2.CategoryView do
  use Ello.Web, :view
  alias Ello.V2.{ImageView,PromotionalView}

  def render("index.json", %{categories: categories}) do
    promotionals = Enum.flat_map(categories, &(&1.promotionals))
    %{
      categories: render_many(categories, __MODULE__, "category.json"),
      linked: %{
        promotionals: render_many(promotionals, PromotionalView, "promotional.json"),
      }
    }
  end

  def render("show.json", %{category: category}) do
    %{
      categories: render_one(category, __MODULE__, "category.json"),
      linked: %{
        promotionals: render_many(category.promotionals, PromotionalView, "promotional.json"),
      }
    }
  end

  @attributes [
    :name,
    :cta_caption,
    :cta_href,
    :description,
    :header,
    :is_sponsored,
    :level,
    :order,
    :slug,
    :uses_page_promotionals,
  ]

  def render("category.json", %{category: category}) do
    category
    |> Map.take(@attributes)
    |> Map.merge(%{
      id: "#{category.id}",
      tile_image: render(ImageView, "image.json", model: category, attribute: :tile_image),
      links: %{
        promotionals: Enum.map(category.promotionals, &("#{&1.id}")),
        recent: %{related: related_link(category)},
      }
    })
  end

  defp related_link(%{slug: slug}) do
    "/api/v2/categories/#{slug}/posts/recent"
  end
end
