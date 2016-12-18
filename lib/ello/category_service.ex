defmodule Ello.CategoryService do
  import Ecto.Query
  alias Ello.{Category,Repo,UserService}

  @moduledoc """
  Responsible for retreiving and loading categories and related data.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @doc "Find a single category by slug or id"
  def find(slug, current_user) when is_binary(slug) do
    Category
    |> Repo.get_by!(slug: slug)
    |> with_related(current_user)
  end
  def find(id, current_user) when is_number(id) do
    Category
    |> Repo.get!(id)
    |> with_related(current_user)
  end

  @doc "Return all Categories and relations, including inactive and meta"
  def all(current_user) do
    Category
    |> Repo.all
    |> with_related(current_user)
  end

  @doc "Return active Categories and relations, including meta"
  def active_with_meta(current_user) do
    Category
    |> active
    |> priority_order
    |> Repo.all
    |> with_related(current_user)
  end

  @doc "Return active Categories and relations, with out meta categories"
  def active_without_meta(current_user) do
    Category
    |> active
    |> exclude_meta
    |> priority_order
    |> Repo.all
    |> with_related(current_user)
    |> preload_counts
  end

  # Scopes
  defp active(q),         do: where(q, [c], not is_nil(c.level))
  defp priority_order(q), do: order_by(q, [:level, :order])
  defp exclude_meta(q),   do: where(q, [c], c.level != "meta")

  # Preloads
  defp with_related(q, nil), do: Repo.preload(q, promotionals: :user)
  defp with_related(q, %{id: id}) do
    # Preload the relationship the current user has to the subjects - in one query
    current_user_relationships = where(Ello.Relationship, owner_id: ^id)
    Repo.preload(q, promotionals: [user: [relationship_to_current_user: current_user_relationships]])
  end

  # TODO: This should probably be extracted to it's own module.
  # Not sure what that looks like, but this could be cleaned up with ETS or a
  # local in memory cache or similar.
  defp preload_counts(categories) do

    # Gather all users
    users = categories
            |> Enum.flat_map(&(&1.promotionals))
            |> Enum.map(&(&1.user))
            |> Enum.uniq_by(&(&1.id))

    users_with_counts = UserService.prefetch_counts(users)

    counted_users_by_id = Enum.group_by(users_with_counts, &(&1.id))

    # Replace users in relationships with preloded users.
    Enum.map categories, fn(cat) ->
      promotionals = Enum.map cat.promotionals, fn(promo) ->
        Map.put(promo, :user, hd(counted_users_by_id[promo.user.id]))
      end
      Map.put(cat, :promotionals, promotionals)
    end
  end
end
