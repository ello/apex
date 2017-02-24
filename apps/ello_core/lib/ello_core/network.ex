defmodule Ello.Core.Network do
  import Ecto.Query
  alias Ello.Core.{Repo,Redis,Network,Discovery}
  alias Network.{User,Relationship}

  @moduledoc """
  Responsible for retrieving and loading users and relationships.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @doc """
  Get a single user by id.

  Includes postgres info and bulk fetched redis info.

  If the current_user is passed in the user relationship will also be included.
  """
  @spec user(id :: integer | String.t, current_user :: User.t | nil) :: User.t
  def user(id_or_username, current_user \\ nil, preload \\ true)
  def user("~" <> username, current_user, preload) do
    user = User
           |> Repo.get_by(username: username)
    if preload do
      user_preloads(user, current_user)
    else
      user
    end
  end
  def user(id, current_user, preload) do
    user = User
           |> Repo.get(id)
    if preload do
      user_preloads(user, current_user)
    else
      user
    end
  end

  @doc """
  Load a user as current user.

  This is intended to be the user as needed for querying the network based on
  user relationships.

  Skips preloads (for performance):
    * categories
    * counts

  Includes preloads (for querying):
    * blocked user ids
    * inverse blocked user ids
  """
  def load_current_user(id) do
    User
    |> Repo.get(id)
    |> User.preload_blocked_ids
  end

  @doc """
  Get multiple users by ids.

  Includes postgres info and bulk fetched redis info.

  If the current_user is passed in the user relationship will also be included.
  """
  @spec users(ids :: [integer], current_user :: User.t | nil) :: [User.t]
  def users(ids, current_user \\ nil) do
    User
    |> where([u], u.id in ^ids)
    |> Repo.all
    |> user_preloads(current_user)
  end

  defp user_preloads(nil, _), do: nil
  defp user_preloads([], _), do: []
  defp user_preloads(user_or_users, current_user) do
    user_or_users
    |> preload_current_user_relationship(current_user)
    |> prefetch_user_counts
    |> prefetch_categories
    |> build_image_structs
  end

  defp preload_current_user_relationship(users, nil), do: users
  defp preload_current_user_relationship(users, %{id: id}) do
    current_user_query = where(Relationship, owner_id: ^id)
    Repo.preload(users, [relationship_to_current_user: current_user_query])
  end

  defp prefetch_user_counts([]), do: []
  defp prefetch_user_counts(%User{} = user),
    do: hd(prefetch_user_counts([user]))
  defp prefetch_user_counts(users) do
    # Get counts from redis
    {:ok, counts} = Redis.command(["MGET" | count_keys_for_users(users)], name: :user_counts)

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

  defp count_keys_for_users(users) do
    # Get keys for each counter
    Enum.flat_map users, fn(%{id: id}) ->
      [
        "user:#{id}:followers_counter",
        "user:#{id}:followed_users_counter",
        "user:#{id}:loves_counter",
        "user:#{id}:posts_counter",
      ]
    end
  end

  defp prefetch_categories(user_or_users) do
    Discovery.put_belongs_to_many_categories(user_or_users)
  end

  defp build_image_structs(%User{} = user), do: User.load_images(user)
  defp build_image_structs(users) do
    Enum.map(users, &build_image_structs/1)
  end
end
