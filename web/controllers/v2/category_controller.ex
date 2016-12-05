defmodule Ello.V2.CategoryController do
  use Ello.Web, :controller
  alias Ello.Category

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
  def show(conn, %{"id" => slug}) do
    render(conn, category: Repo.get_by!(Category, slug: slug))
  end

  defp categories(%{"all" => _}) do
    Repo.all(Category)
  end
  defp categories(%{"meta" => _}) do
    Category
    |> where([c], not is_nil(c.level))
    |> order_by([:level, :order])
    |> Repo.all
  end
  defp categories(_) do
    Category
    |> where([c], not is_nil(c.level))
    |> where([c], c.level != "meta")
    |> order_by([:level, :order])
    |> Repo.all
  end
end
