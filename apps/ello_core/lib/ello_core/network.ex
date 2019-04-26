defmodule Ello.Core.Network do
  import Ello.Core
  import Ecto.Query
  # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
  # newrelic until we have bandwidth to update our code, maybe to new_relic
  # import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.{Repo, Redis}
  alias __MODULE__.{User, Preload, Relationship, Flag}

  @moduledoc """
  Responsible for retrieving and loading users and relationships.

  Handles database queryies, preloading relations, and fetching cached values.
  """

  @typedoc """
  All Ello.Core.Content public functions except load_current_user expect to
  receive a map of options. Those options should always include `current_user`.
  """
  @type options :: %{
    required(:current_user)   => User.t | nil,
    optional(:preload)        => boolean,
    optional(:id_or_username) => integer | String.t,
    optional(:ids)          => [integer],
    optional(any)           => any
  }

  @doc """
  Get a single user.

  Options:

  * id_or_username - id or username to look up. Username should be pre-pended with `~`
  * current_user - For determining relationship to current user.
  * preload - preload counts etc? Default true.
  """
  @spec user(options) :: User.t
  def user(%{id_or_username: "~" <> username} = options) do
    User
    |> Repo.get_by(username: String.downcase(username))
    |> Preload.users(options)
  end
  def user(%{id_or_username: id} = options) do
    User
    |> Repo.get(id)
    |> Preload.users(options)
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
    |> Repo.preload(:category_users)
    |> User.preload_blocked_ids
    |> Preload.is_spammer
  end

  @doc """
  Load a user with no preloads for the sake of post view tracking.

  Requires id or email.
  """
  def load_view_tracking_user(%{email: email}), do:
    Repo.get_by(User, email: String.downcase(email))
  def load_view_tracking_user(%{id: id}), do:
    Repo.get(User, id)

  @doc """
  Get multiple users.

  * ids - ids of users to retreive
  * current_user - For determining relationship to current user.
  * preload - preload counts etc? Default true.
  """
  @spec users(options) :: [User.t]
  def users(%{ids: ids} = options) do
    User
    |> where([u], u.id in ^ids)
    |> Repo.all
    |> user_sorting(ids)
    |> Preload.users(options)
  end

  def relationships(%{followers: %{id: user_id}} = options) do
    Relationship
    |> where([r], r.subject_id == ^user_id)
    |> where([r], r.priority in ["friend", "noise"]) # Need to optimize
    |> paginate(options)
    |> Repo.all
    |> Preload.relationships(options)
  end

  def relationships(%{following: %{id: user_id}} = options) do
    Relationship
    |> where([r], r.owner_id == ^user_id)
    |> where([r], r.priority in ["friend", "noise"]) # Need to optimize
    |> paginate(options)
    |> Repo.all
    |> Preload.relationships(options)
  end

  def paginate(query, options) do
    per_page = options[:per_page] || 25

    query = case parse_before(options[:before]) do
      nil    -> query
      before ->
        where(query, [r], r.created_at < ^before)
    end

    query
    |> order_by([r], desc: r.created_at)
    |> limit(^per_page)
  end

  defp user_sorting(users, ids) do
    measure_segment {__MODULE__, "user_sorting"} do
      mapped = Enum.group_by(users, &(&1.id))
      ids
      |> Enum.uniq
      |> Enum.flat_map(&(mapped[&1] || []))
    end
  end

  @following_ids_limit 10_000

  @doc """
  Gets all the user ids that are followed by a user.
  """
  @spec following_ids(user :: User.t, limit :: integer) :: [integer]
  def following_ids(user, limit \\ @following_ids_limit) do
    redis_key = "user:#{user.id}:followed_users_id_cache"
    {:ok, [_, following_ids]} = Redis.command(["SSCAN", redis_key, 0, "COUNT", limit], name: :following_ids)
    following_ids
  end

  def flags_exist?(%{kind: kind, user: %{id: id}, verified: verified}) do
    Flag
    |> where(kind: ^kind, verified: ^verified, subject_user_id: ^id)
    |> Repo.exists
  end
end
