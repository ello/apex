defmodule Ello.Core.Content do
  import Ecto.Query
  alias Ello.Core.{
    Repo,
    Redis,
    Network,
    Discovery,
  }
  alias __MODULE__.{
    PostsPage,
    Post,
    Love,
    Watch,
    Asset,
  }

  @moduledoc """
  Responsible for retrieving and loading posts, comments, and related assets.

  Handles database queryies, preloading reposts, and fetching cached values.
  """

  @doc """
  Get a post by id or token.

  Includes postgres info and bulk fetched redis info.

  If the current_user is passed in the reposted/wathched/loved relationship will
  also be included, and the post will be filtered based on blocked users, nsfw
  and nudity content visibility, and posts by banned users.  If no user is
  present, posts by private users will not be included.
  """

  @type filter_opts :: %{current_user: User.t | nil, allow_nsfw: boolean, allow_nudity: boolean}

  def post(id_or_slug, opts) when is_list(opts), do: post(id_or_slug, Enum.into(opts, %{}))

  @spec post(id_or_slug :: String.t | integer, filters :: filter_opts) :: Post.t
  def post("~" <> slug, %{current_user: current_user} = filters) do
    Post
    |> filter_post_for_client(filters)
    |> Repo.get_by(token: slug)
    |> post_preloads(current_user)
    |> filter_blocked(current_user)
  end
  def post(id, %{current_user: current_user} = filters) do
    Post
    |> filter_post_for_client(filters)
    |> Repo.get(id)
    |> post_preloads(current_user)
    |> filter_blocked(current_user)
  end

  def posts_by_user(user_id, opts) when is_list(opts), do: posts_by_user(user_id, Enum.into(opts, %{}))

  @spec posts_by_user(user_id :: integer, filters :: any) :: PostsPage.t
  def posts_by_user(user_id, %{} = filters) do
    per_page = filters[:per_page] || 25
    total_query = Post
            |> filter_post_for_client(filters)
            |> where([p], p.author_id == ^user_id and is_nil(p.parent_post_id))
    total_count = total_query
                  |> select([p], count(p.id))
                  |> Repo.one

    remaining_query = case filters[:before] do
      nil  -> total_query
      date -> where(total_query, [p], p.created_at < ^date)
    end
    remaining_count = Repo.aggregate(remaining_query, :count, :id)

    query = remaining_query
            |> order_by([p], [desc: p.created_at])
            |> limit(^per_page)
    posts = Repo.all(query)
    last_post_date = case List.last(posts) do
      nil -> nil
      last_post -> last_post.created_at
    end

    %PostsPage{
      posts: posts,
      total_pages: round(Float.ceil(total_count / per_page)),
      total_count: total_count,
      total_pages_remaining: round(Float.ceil(remaining_count / per_page)),
      before: last_post_date,
    }
  end

  defp filter_post_for_client(query, %{current_user: current_user, allow_nsfw: allow_nsfw, allow_nudity: allow_nudity}) do
    query
    |> filter_nsfw(allow_nsfw)
    |> filter_nudity(allow_nudity)
    |> filter_banned
    |> filter_private(current_user)
  end

  defp filter_nsfw(query, true), do: query
  defp filter_nsfw(query, false), do: where(query, [p], not p.is_adult_content)

  defp filter_nudity(query, true), do: query
  defp filter_nudity(query, false), do: where(query, [p], not p.has_nudity)

  defp filter_blocked(nil, _), do: nil
  defp filter_blocked([], _), do: []
  defp filter_blocked(post_or_posts, nil), do: post_or_posts
  defp filter_blocked(post_or_posts, %{all_blocked_ids: %{map: blocked}})
       when map_size(blocked) == 0,
       do: post_or_posts
  defp filter_blocked(%Post{} = post, %{all_blocked_ids: blocked}),
    do: if is_blocked(post, blocked), do: nil, else: post
  defp filter_blocked(posts, %{all_blocked_ids: blocked}),
    do: Enum.reject(posts, &is_blocked(&1, blocked))

  defp is_blocked(%{reposted_source: %{author_id: rp_id}, author_id: id}, blocked),
    do: id in blocked || rp_id in blocked
  defp is_blocked(%{author_id: id}, blocked),
    do: id in blocked

  defp filter_banned(query) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], is_nil(a.locked_at) and is_nil(rpa.locked_at))
  end

  defp filter_private(query, nil) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], a.is_public and (is_nil(rpa.is_public) or rpa.is_public))
  end
  defp filter_private(query, _), do: query

  defp post_preloads(post_or_posts, current_user) do
    post_or_posts
    |> post_and_repost_preloads(current_user)
    |> prefetch_reposted_source(current_user)
  end

  defp repost_preloads(reposts, current_user) do
    reposts
    |> post_and_repost_preloads(current_user)
    |> Enum.map(&(nilify_reposted_source(&1)))
  end

  defp nilify_reposted_source(repost) do
    Map.put(repost, :reposted_source, nil)
  end

  defp post_and_repost_preloads(posts, current_user) do
    posts
    |> prefetch_categories
    |> prefetch_assets_and_author(current_user)
    |> prefetch_current_user_relationships(current_user)
    |> prefetch_post_counts
    |> build_image_structs
  end

  defp prefetch_assets_and_author(nil, _), do: nil
  defp prefetch_assets_and_author([], _), do: []
  defp prefetch_assets_and_author(post_or_posts, current_user) do
    Repo.preload(post_or_posts, [assets: [], author: &Network.users(&1, current_user)])
  end

  defp prefetch_reposted_source(nil, _), do: nil
  defp prefetch_reposted_source([], _), do: []
  defp prefetch_reposted_source(post_or_posts, current_user) do
    Repo.preload post_or_posts, reposted_source: fn(ids) ->
      Post
      |> where([p], p.id in ^ids)
      |> Repo.all
      |> repost_preloads(current_user)
    end
  end

  defp prefetch_current_user_relationships(post_or_posts, nil), do: post_or_posts
  defp prefetch_current_user_relationships(nil, _), do: nil
  defp prefetch_current_user_relationships([], _), do: []
  defp prefetch_current_user_relationships(post_or_posts, %{id: id}) do
    current_user_repost_query = where(Post, author_id: ^id)
    current_user_love_query = where(Love, user_id: ^id)
    current_user_watch_query = where(Watch, user_id: ^id)
    Repo.preload(post_or_posts, [
      repost_from_current_user: current_user_repost_query,
      love_from_current_user:   current_user_love_query,
      watch_from_current_user:  current_user_watch_query,
    ])
  end

  # Because categories are stored as an array on posts we can use preload.
  # Instead we basically do what preload does ourselves manually.
  defp prefetch_categories(post_or_posts) do
    Discovery.put_belongs_to_many_categories(post_or_posts)
  end

  defp prefetch_post_counts(nil), do: nil
  defp prefetch_post_counts([]), do: []
  defp prefetch_post_counts(%Post{} = post),
    do: hd(prefetch_post_counts([post]))
  defp prefetch_post_counts(posts) do
    # Get counts from redis
    {:ok, counts} = Redis.command(["MGET" | count_keys_for_posts(posts)], name: :post_counts)

    # Add counts to posts
    counts
    |> Enum.map(&(String.to_integer(&1 || "0")))
    |> Enum.chunk(4)
    |> Enum.zip(posts)
    |> Enum.map(fn({[loves, comments, reposts, views], user}) ->
      Map.merge user, %{
        loves_count:    loves,
        comments_count: comments,
        reposts_count:  reposts,
        views_count:    views,
      }
    end)
  end

  defp count_keys_for_posts(posts) do
    # Get keys for each counter
    Enum.flat_map posts, fn(%{id: id}) ->
      [
        "post:#{id}:love_counter",
        "post:#{id}:comment_counter",
        "post:#{id}:repost_counter",
        "post:#{id}:view_counter",
      ]
    end
  end

  defp build_image_structs(%Post{assets: assets} = post) when is_list(assets) do
    built_assets = assets
                   |> Enum.reject(&(is_nil(&1.attachment)))
                   |> Enum.map(&Asset.build_attachment/1)
    Map.put(post, :assets, built_assets)
  end
  defp build_image_structs(%Post{} = post), do: post
  defp build_image_structs(nil), do: nil
  defp build_image_structs(posts) when is_list(posts) do
    Enum.map(posts, &build_image_structs/1)
  end
end
