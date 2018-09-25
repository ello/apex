defmodule Ello.V2.CategoryView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{ImageView, PromotionalView, UserView}

  def stale_checks(_, %{data: categories}) do
    [etag: etag(categories)]
  end

  def render("index.json", %{data: categories} = opts) do
    promotionals = Enum.flat_map(categories, &(&1.promotionals))
    users = Enum.map(promotionals, &(&1.user))
    brand_accounts = Enum.map(categories, &pluck_brand_account/1)

    json_response()
    |> render_resource(:categories, categories, __MODULE__, opts)
    |> include_linked(:promotionals, promotionals, PromotionalView, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:brand_account, brand_accounts, UserView, opts)
  end

  @doc "Render categories and relations for /api/v2/categories/:id"
  def render("show.json", %{data: category} = opts) do
    users = Enum.map(category.promotionals, &(&1.user))

    json_response()
    |> render_resource(:categories, category, __MODULE__, opts)
    |> include_linked(:promotionals, category.promotionals, PromotionalView, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:brand_account, pluck_brand_account(category), UserView, opts)
  end

  @doc "Render a single category as included in other reponses"
  def render("category.json", %{category: category} = opts) do
    render_self(category, __MODULE__, opts)
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
    :is_creator_type,
  ]

  def computed_attributes, do: [
    :header,
    :tile_image
  ]

  def tile_image(category, conn) do
    render(ImageView, "image.json", image: category.tile_image_struct, conn: conn)
  end

  # Only link promotionals if they are preloaded - this does not happen when
  # sideloading categories with users.
  def links(%{promotionals: promos} = category, _) when is_list(promos) do
    %{
      brand_account: brand_account(category),
      promotionals: Enum.map(promos, &("#{&1.id}")),
      recent: %{related: related_link(category)},
    }
  end
  def links(category, _) do
    %{
      brand_account: brand_account(category),
      recent: %{related: related_link(category)},
    }
  end

  defp pluck_brand_account(%{brand_account: %Ello.Core.Network.User{} = brand_account}), do: brand_account
  defp pluck_brand_account(_), do: nil

  defp brand_account(%{brand_account: %Ello.Core.Network.User{} = user}) do
    %{
      id: "#{user.id}",
      type: "users",
      href: "/api/v2/users/#{user.id}",
    }
  end
  defp brand_account(_), do: nil

  defp related_link(%{slug: slug}) do
    "/api/v2/categories/#{slug}/posts/recent"
  end

  def header(%{header: nil, name: name}, _), do: name
  def header(%{header: "", name: name}, _),  do: name
  def header(%{header: header, name: _}, _), do: header
end
