defmodule Ello.CategoryService do
  import Ecto.Query
  alias Ello.{Category,Repo}

  @moduledoc """
  Responsible for retreiving and loading categories and related data.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @doc "Find a single category by slug or id"
  def find(slug) when is_binary(slug) do
    Category
    |> Repo.get_by!(slug: slug)
    |> with_related
  end
  def find(id) when is_number(id) do
    Category
    |> Repo.get!(id)
    |> with_related
  end

  @doc "Return all Categories and relations, including inactive and meta"
  def all do
    Category
    |> Repo.all
    |> with_related
  end

  @doc "Return active Categories and relations, including meta"
  def active_with_meta do
    Category
    |> active
    |> priority_order
    |> Repo.all
    |> with_related
  end

  @doc "Return active Categories and relations, with out meta categories"
  def active_without_meta do
    Category
    |> active
    |> exclude_meta
    |> priority_order
    |> Repo.all
    |> with_related
  end

  # Scopes
  defp active(q),         do: where(q, [c], not is_nil(c.level))
  defp priority_order(q), do: order_by(q, [:level, :order])
  defp exclude_meta(q),   do: where(q, [c], c.level != "meta")

  # Preloads
  defp with_related(q), do: Repo.preload(q, promotionals: :user)
end
