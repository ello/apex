defmodule Ello.V2.CategoryController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Discovery

  @doc """
  GET /v2/categories

  Render index listing of categories in existing v2 API format.

  Supports `meta=true` and `all=true` params.
  """
  def index(conn, params) do
    api_render_if_stale(conn, data: categories(conn, params))
  end

  @doc """
  GET /v2/categories/:slug_as_id

  Render a single category by slug
  """
  def show(conn, %{"id" => id_or_slug}) do
    category = Discovery.category(standard_params(conn, %{id_or_slug: id_or_slug, promotionals: true}))
    api_render_if_stale(conn, data: category)
  end

  defp categories(conn, %{"all" => _}),
    do: Discovery.categories(standard_params(conn, %{meta: true, inactive: true, promotionals: true}))
  defp categories(conn, %{"meta" => _}),
    do: Discovery.categories(standard_params(conn, %{meta: true, promotionals: true}))
  defp categories(conn, _),
    do: Discovery.categories(standard_params(conn, %{promotionals: true}))
end
