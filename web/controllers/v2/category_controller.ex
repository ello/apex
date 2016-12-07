defmodule Ello.V2.CategoryController do
  use Ello.Web, :controller
  alias Ello.CategoryService

  @doc """
  GET /v2/categories

  Render index listing of categories in existing v2 API format.

  Supports `meta=true` and `all=true` params.
  """
  def index(conn, params) do
    render(conn, categories: categories(params))
  end

  @doc """
  GET /v2/categories/:slug_as_id

  Render a single category by slug
  """
  def show(conn, %{"id" => id_or_slug}) do
    render(conn, category: CategoryService.find(id_or_slug))
  end

  defp categories(%{"all" => _}),  do: CategoryService.all
  defp categories(%{"meta" => _}), do: CategoryService.active_with_meta
  defp categories(_),              do: CategoryService.active_without_meta
end
