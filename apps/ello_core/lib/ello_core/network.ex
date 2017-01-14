defmodule Ello.Core.Network do
  import Ecto.Query
  alias Ello.Core.{Repo,Redis,Network}
  alias Network.{User,Relationship}

  @moduledoc """
  Responsible for retreiving and loading users and relationships.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @doc """
  Get users by ids.

  Includes postgres info and bulk fetched redis info.

  If the current_user is passed in the user relationship will also be included.
  """
  @spec users(ids :: [integer], current_user :: User.t | nil) :: [User.t]
  def users(ids, current_user \\ nil) do
    User
    |> where([u], u.id in ^ids)
    |> Repo.all
    |> preload_current_user_relationship(current_user)
    |> prefetch_user_counts
  end

  defp preload_current_user_relationship(users, nil), do: users
  defp preload_current_user_relationship(users, %{id: id}) do
    current_user_query = where(Relationship, owner_id: ^id)
    Repo.preload(users, [relationship_to_current_user: current_user_query])
  end

  defp prefetch_user_counts([]), do: []
  defp prefetch_user_counts(users) do
    # Get keys for each counter
    keys = Enum.flat_map users, fn(%{id: id}) ->
      [
        "user:#{id}:followers_counter",
        "user:#{id}:followed_users_counter",
        "user:#{id}:loves_counter",
        "user:#{id}:posts_counter",
      ]
    end

    # Get counts from redis
    {:ok, counts} = Redis.command(["MGET" | keys])

    # Add counts to users
    counts
    |> Enum.map(&(String.to_integer(&1 || "0")))
    |> Enum.chunk(4)
    |> Enum.zip(users)
    |> Enum.map(fn({[followers, following, loves, posts], user}) ->
      Map.merge user, %{
        loves_count:     loves,
        posts_count:     posts,
        following_count: following,
        followers_count: followers,
      }
    end)
  end
end
