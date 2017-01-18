defmodule Ello.V2.CategoryView do
  use Ello.V2.Web, :view
  alias Ello.V2.{ImageView,PromotionalView,UserView}

  def render("index.json", %{categories: categories, conn: conn}) do
    promotionals = Enum.flat_map(categories, &(&1.promotionals))
    users = Enum.map(promotionals, &(&1.user))
    %{
      categories: render_many(categories, __MODULE__, "category.json"),
      linked: %{
        promotionals: render_many(promotionals, PromotionalView, "promotional.json"),
        users: render_many(users, UserView, "user.json", conn: conn),
      }
    }
  end

  def render("show.json", %{category: category, conn: conn}) do
    users = Enum.map(category.promotionals, &(&1.user))
    %{
      categories: render_one(category, __MODULE__, "category.json"),
      linked: %{
        promotionals: render_many(category.promotionals, PromotionalView, "promotional.json"),
        users: render_many(users, UserView, "user.json", conn: conn),
      }
    }
  end

  @attributes [
    :name,
    :cta_caption,
    :cta_href,
    :description,
    :is_sponsored,
    :level,
    :order,
    :slug,
    :uses_page_promotionals,
    :allow_in_onboarding,
  ]

  def render("category.json", %{category: category}) do
    category
    |> Map.take(@attributes)
    |> Map.merge(%{
      id: "#{category.id}",
      header: header(category),
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


  defp header(%{header: nil, name: name}), do: name
  defp header(%{header: "", name: name}),  do: name
  defp header(%{header: header, name: _}), do: header
end