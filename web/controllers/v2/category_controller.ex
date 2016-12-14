defmodule Ello.V2.CategoryController do
  use Ello.Web, :controller
  alias Ello.CategoryService

  @doc """
  GET /v2/categories

  Render index listing of categories in existing v2 API format.

  Supports `meta=true` and `all=true` params.
  """
  def index(conn, params) do
    render(conn, categories: categories(params, conn))
  end

  @doc """
  GET /v2/categories/:slug_as_id

  Render a single category by slug
  """
  def show(conn, %{"id" => id_or_slug}) do
    render(conn, category: CategoryService.find(id_or_slug, current_user(conn)))
  end

  defp categories(%{"all" => _}, conn),  do: CategoryService.all(current_user(conn))
  defp categories(%{"meta" => _}, conn), do: CategoryService.active_with_meta(current_user(conn))
  defp categories(_, conn),              do: CategoryService.active_without_meta(current_user(conn))

  defp current_user(%{assigns: %{user: user}}), do: user
  defp current_user(_), do: nil
end
