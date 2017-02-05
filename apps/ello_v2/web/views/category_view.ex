defmodule Ello.V2.CategoryView do
  use Ello.V2.Web, :view
  alias Ello.V2.{ImageView,PromotionalView,UserView}

  def render("index.json", %{categories: categories} = opts) do
    promotionals = Enum.flat_map(categories, &(&1.promotionals))
    users = Enum.map(promotionals, &(&1.user))

    render_resource(:categories, categories, __MODULE__, opts)
    |> include_resource(:promotionals, promotionals, PromotionalView, opts)
    |> include_resource(:users, users, UserView, opts)
  end

  def render("show.json", %{category: category} = opts) do
    users = Enum.map(category.promotionals, &(&1.user))

    render_resource(:categories, category, __MODULE__, opts)
    |> include_resource(:promotionals, category.promotionals, PromotionalView, opts)
    |> include_resource(:users, users, UserView, opts)
  end

  def attributes, do: [
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

  def computed_attributes, do: [
    :header, :tile_image, :links
  ]

  def render("category.json", %{category: category} = opts) do
    render_self(category, __MODULE__, opts)
  end

  def tile_image(category, %{conn: conn}) do
    render(ImageView, "image.json", image: category.tile_image_struct, conn: conn)
  end

  # Only link promotionals if they are preloaded - this does not happen when
  # sideloading categories with users.
  def links(%{promotionals: promos} = category, _) when is_list(promos) do
    %{
      promotionals: Enum.map(promos, &("#{&1.id}")),
      recent: %{related: related_link(category)},
    }
  end
  def links(category, _) do
    %{
      recent: %{related: related_link(category)},
    }
  end

  defp related_link(%{slug: slug}) do
    "/api/v2/categories/#{slug}/posts/recent"
  end

  def header(%{header: nil, name: name}, _), do: name
  def header(%{header: "", name: name}, _),  do: name
  def header(%{header: header, name: _}, _), do: header
end
