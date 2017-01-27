defmodule Ello.Core.Discovery do
  import Ecto.Query
  alias Ello.Core.{Repo, Network, Discovery}
  alias Discovery.Category
  alias Network.User

  @moduledoc """
  Responsible for retreiving and loading categories and related data.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @doc "Find a single category by slug or id - including promotionals"
  @spec category(String.t | integer, current_user :: User.t | nil) :: Category.t
  def category(id_or_slug, current_user \\ nil)
  def category(slug, current_user) when is_binary(slug) do
    Category
    |> Repo.get_by!(slug: slug)
    |> include_promotionals(current_user)
  end
  def category(id, current_user) when is_number(id) do
    Category
    |> Repo.get!(id)
    |> include_promotionals(current_user)
  end

  def categories_by_ids(ids) when is_list(ids) do
    Category
    |> where([c], c.id in ^ids)
    |> include_inactive_categories(false)
    |> include_meta_categories(false)
    |> Repo.all
  end

  @doc """
  Return all Categories with related promotionals their user.

  By default neither "meta" categories nor "inactive" categories are included
  in the results. Pass `meta: true` or `inactive: true` as opts to include them.
  """
  @spec categories(current_user :: User.t, opts :: Keyword.t) :: [Category.t]
  def categories(current_user \\ nil, opts \\ []) do
    Category
    |> include_inactive_categories(opts[:inactive])
    |> include_meta_categories(opts[:meta])
    |> priority_order
    |> Repo.all
    |> include_promotionals(current_user)
  end

  # Category Scopes
  defp priority_order(q),
    do: order_by(q, [:level, :order])

  defp include_inactive_categories(q, true), do: q
  defp include_inactive_categories(q, _),
    do: where(q, [c], not is_nil(c.level))

  defp include_meta_categories(q, true), do: q
  defp include_meta_categories(q, _),
    do: where(q, [c], c.level != "meta" or is_nil(c.level))

  defp include_promotionals(categories, current_user) do
    Repo.preload(categories, promotionals: [user: &Network.users(&1, current_user)])
  end
end
