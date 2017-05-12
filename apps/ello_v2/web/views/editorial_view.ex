defmodule Ello.V2.EditorialView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{
    PostView,
    CategoryView,
    UserView,
    AssetView,
  }

  def stale_checks(_, %{data: editorials}) do
    [etag: etag(editorials)]
  end

  def render("index.json", %{data: editorials} = opts) do
    posts     = editorials |> Enum.map(&(&1.post)) |> Enum.reject(&is_nil/1)
    reposts   = posts |> Enum.map(&(&1.reposted_source)) |> Enum.reject(&is_nil/1)
    all_posts = posts ++ reposts
    users     = Enum.map(all_posts, &(&1.author))
    assets    = Enum.flat_map(all_posts, &(&1.assets))
    categories = Enum.flat_map(all_posts ++ users, &(&1.categories))

    json_response()
    |> render_resource(:editorials, editorials, __MODULE__, opts)
    |> include_linked(:posts, all_posts, PostView, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:categories, categories, CategoryView, opts)
    |> include_linked(:assets, assets, AssetView, opts)
  end

  def render("editorial.json", %{editorial: editorial} = opts) do
    editorial
    |> render_self(__MODULE__, opts)
  end

  def attributes, do: [
  ]

  def computed_attributes, do: [
  ]
end
