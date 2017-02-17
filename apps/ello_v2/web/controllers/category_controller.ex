defmodule Ello.V2.CategoryController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Discovery

  @doc """
  GET /v2/categories

  Render index listing of categories in existing v2 API format.

  Supports `meta=true` and `all=true` params.
  """
  def index(conn, params) do
    render_if_stale(conn, categories: categories(params, conn))
  end

  @doc """
  GET /v2/categories/:slug_as_id

  Render a single category by slug
  """
  def show(conn, %{"id" => id_or_slug}) do
    render(conn, category: Discovery.category(id_or_slug, current_user(conn)))
  end

  defp categories(%{"all" => _}, conn),  do: Discovery.categories(current_user(conn), meta: true, inactive: true)
  defp categories(%{"meta" => _}, conn), do: Discovery.categories(current_user(conn), meta: true)
  defp categories(_, conn),              do: Discovery.categories(current_user(conn))
end
