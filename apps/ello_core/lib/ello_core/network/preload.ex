defmodule Ello.Core.Network.Preload do
  import Ecto.Query
  alias Ello.Core.{Repo,Redis,Network,Discovery}
  alias Network.{User,Relationship}

  @user_default_preloads %{
    current_user_state: %{},
    user_stats: %{},
    categories: %{},
  }

  def relationships([], _), do: []
  def relationships(rels, options) do
    Repo.preload(rels, [
      owner:   &Network.users(%{ids: &1, current_user: options[:current_user]}),
      subject: &Network.users(%{ids: &1, current_user: options[:current_user]}),
    ])
  end

  def users(nil, _), do: nil
  def users([], _),  do: []
  def users(user_or_users, %{preload: false}), do: user_or_users
  def users(user_or_users, %{preloads: %{}} = options) do
    user_or_users
    |> preload_current_user_relationship(options)
    |> prefetch_user_counts(options)
    |> prefetch_categories(options)
    |> build_image_structs
  end
  def users(user_or_users, options) do
    users(user_or_users, Map.put(options, :preloads, @user_default_preloads))
  end

  def is_spammer(user) do
    Map.put(user, :is_spammer, Network.flags_exist?(%{user: user, kind: "spam", verified: true}))
  end

  defp preload_current_user_relationship(users, %{current_user: %{id: id}, preloads: %{current_user_state: _}}) do
    current_user_query = where(Relationship, owner_id: ^id)
    Repo.preload(users, [relationship_to_current_user: current_user_query])
  end
  defp preload_current_user_relationship(users, _), do: users

  defp prefetch_user_counts(%User{} = user, options),
    do: hd(prefetch_user_counts([user], options))
  defp prefetch_user_counts(users, %{preloads: %{user_stats: _}}) do
    # Get counts from redis
    {:ok, counts} = Redis.command(["MGET" | count_keys_for_users(users)], name: :user_counts)

    # Add counts to users
    counts
    |> Enum.map(&(String.to_integer(&1 || "0")))
    |> Enum.chunk(5)
    |> Enum.zip(users)
    |> Enum.map(&merge_user_counts/1)
  end
  defp prefetch_user_counts(users, _), do: users

  defp merge_user_counts({[_, _, loves, posts, total_views], %{is_system_user: true} = user}) do
    Map.merge user, %{
      loves_count:        loves,
      posts_count:        posts,
      following_count:    0,
      followers_count:    0,
      total_views_count:  total_views
    }
  end
  defp merge_user_counts({[followers, following, loves, posts, total_views], user}) do
    Map.merge user, %{
      loves_count:        loves,
      posts_count:        posts,
      following_count:    following,
      followers_count:    followers,
      total_views_count:  total_views
    }
  end

  defp count_keys_for_users(users) do
    # Get keys for each counter
    Enum.flat_map users, fn(%{id: id}) ->
      [
        "user:#{id}:followers_counter",
        "user:#{id}:followed_users_counter",
        "user:#{id}:loves_counter",
        "user:#{id}:posts_counter",
        "user:#{id}:total_post_views_counter",
      ]
    end
  end

  defp prefetch_categories(user_or_users, %{preloads: %{categories: _}}) do
    Discovery.put_belongs_to_many_categories(user_or_users)
  end
  defp prefetch_categories(user_or_users, _), do: user_or_users

  defp build_image_structs(%User{} = user), do: User.load_images(user)
  defp build_image_structs(users) do
    Enum.map(users, &build_image_structs/1)
  end
end
