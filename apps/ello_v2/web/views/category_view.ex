defmodule Ello.V2.CategoryView do
  use Ello.V2.Web, :view
  alias Ello.V2.{ImageView,PromotionalView,UserView}

  def render("index.json", %{categories: categories, conn: conn}) do
    promotionals = Enum.flat_map(categories, &(&1.promotionals))
    users = promotionals |> Enum.map(&(&1.user)) |> Enum.uniq_by(&(&1.id))
    %{
      categories: render_many(categories, __MODULE__, "category.json", conn: conn),
      linked: %{
        promotionals: render_many(promotionals, PromotionalView, "promotional.json", conn: conn),
        users: render_many(users, UserView, "user.json", conn: conn),
      }
    }
  end

  def render("show.json", %{category: category, conn: conn}) do
    users = category.promotionals |> Enum.map(&(&1.user)) |> Enum.uniq_by(&(&1.id))
    %{
      categories: render_one(category, __MODULE__, "category.json", conn: conn),
      linked: %{
        promotionals: render_many(category.promotionals, PromotionalView, "promotional.json", conn: conn),
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

  def render("category.json", %{category: category, conn: conn}) do
    category
    |> Map.take(@attributes)
    |> Map.merge(%{
      id: "#{category.id}",
      header: header(category),
      tile_image: render(ImageView, "image.json", image: category.tile_image_struct, conn: conn),
      links: links(category)
    })
  end

  # Only link promotionals if they are preloaded - this does not happen when
  # sideloading categories with users.
  defp links(%{promotionals: promos} = category) when is_list(promos) do
    %{
      promotionals: Enum.map(promos, &("#{&1.id}")),
      recent: %{related: related_link(category)},
    }
  end
  defp links(category) do
    %{
      recent: %{related: related_link(category)},
    }
  end

  defp related_link(%{slug: slug}) do
    "/api/v2/categories/#{slug}/posts/recent"
  end


  defp header(%{header: nil, name: name}), do: name
  defp header(%{header: "", name: name}),  do: name
  defp header(%{header: header, name: _}), do: header
end
