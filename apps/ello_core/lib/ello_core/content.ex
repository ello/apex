defmodule Ello.Core.Content do
  import NewRelicPhoenix, only: [measure_segment: 2]
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

  @spec post(id_or_slug :: String.t | integer, filters :: filter_opts) :: Post.t
  def post(id_or_slug, opts) when is_list(opts), do: post(id_or_slug, Enum.into(opts, %{}))
  def post("~" <> token, %{current_user: current_user} = filters) do
    Post
    |> filter_post_for_client(filters)
    |> Repo.get_by(token: token)
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

  def posts_by_ids(ids, opts) when is_list(opts), do: posts_by_ids(ids, Enum.into(opts, %{}))
  def posts_by_ids(ids, %{current_user: current_user} = filters) do
    Post
    |> where([p], p.id in ^ids)
    |> filter_post_for_client(filters)
    |> Repo.all
    |> post_preloads(current_user)
    |> filter_blocked(current_user)
    |> post_sorting(ids)
  end

  defp post_sorting(posts, ids) do
    measure_segment {__MODULE__, "post_sorting"} do
      mapped = Enum.group_by(posts, &(&1.id))
      Enum.flat_map(ids, fn(id) ->
        mapped[id] || []
      end)
    end
  end

  @type related_filter_opts :: %{current_user: User.t | nil, allow_nsfw: boolean, allow_nudity: boolean, per_page: String.t | integer}
  @spec related_posts(id_or_token :: String.t | integer, filters :: related_filter_opts) :: [Post.t]
  def related_posts(post_id, opts) when is_list(opts),
    do: related_posts(post_id, Enum.into(opts, %{}))
  def related_posts("~" <> token, filters),
    do: get_related_posts(Repo.get_by(Post, token: token), filters)
  def related_posts(id, filters),
    do: get_related_posts(Repo.get(Post, id), filters)

  defp get_related_posts(nil, _), do: {nil, []}
  defp get_related_posts(%Post{id: related_id, author_id: author_id} = related_to,
                         %{current_user: current_user, per_page: per_page} = filters) do
    posts = Post
            |> filter_post_for_client(filters)
            |> where([p], p.author_id == ^author_id)
            |> where([p], p.id != ^related_id)
            |> where([p], is_nil(p.parent_post_id))
            |> order_by(fragment("random()"))
            |> limit(^per_page)
            |> Repo.all
            |> post_preloads(current_user)
            |> filter_blocked(current_user)

    {related_to, posts}
  end

  @spec posts_by_user(user_id :: integer, filters :: any) :: PostsPage.t
  def posts_by_user(user_id, opts) when is_list(opts), do: posts_by_user(user_id, Enum.into(opts, %{}))
  def posts_by_user(user_id, %{} = filters) do
    per_page = parse_per_page(filters[:per_page])
    before = parse_before(filters[:before])

    total_query = total_posts_by_user_query(user_id, filters)
    remaining_query = remaining_posts_by_user_query(total_query, before)

    measure_segment {:db, "Ecto.UserPostsQuery"} do
      posts_task = Task.async(__MODULE__, :page_of_posts_by_user_query, [remaining_query, per_page, filters])
      total_count_task = Task.async(__MODULE__, :count_and_pages_calc, [total_query, per_page])
      remaining_count_task = Task.async(__MODULE__, :count_and_pages_calc, [remaining_query, per_page])

      posts = Task.await(posts_task)
      {total_count, total_pages} = Task.await(total_count_task)
      {_, remaining_pages} = Task.await(remaining_count_task)
    end

    last_post_date = get_last_post_created_at(posts)

    %PostsPage{
      posts: posts,
      total_pages: total_pages,
      total_count: total_count,
      total_pages_remaining: remaining_pages,
      per_page: per_page,
      before: last_post_date,
    }
  end

  defp parse_per_page(per_page) when is_binary(per_page) do
    case Integer.parse(per_page) do
      {val, _} -> val
      _        -> parse_per_page(nil)
    end
  end
  defp parse_per_page(per_page) when is_integer(per_page), do: per_page
  defp parse_per_page(_), do: 25

  defp parse_before(%DateTime{} = before), do: before
  defp parse_before(nil), do: nil
  defp parse_before(before) do
    before
    |> URI.decode
    |> DateTime.from_iso8601
    |> case do
      {:ok, date, _} -> date
      _ -> nil
    end
  end

  defp total_posts_by_user_query(user_id, %{} = filters) do
    Post
    |> filter_post_for_client(filters)
    |> where([p], p.author_id == ^user_id and is_nil(p.parent_post_id))
  end

  defp remaining_posts_by_user_query(total_query, nil), do: total_query
  defp remaining_posts_by_user_query(total_query, date) do
    where(total_query, [p], p.created_at < ^date)
  end

  def page_of_posts_by_user_query(remaining_query, per_page, %{current_user: current_user} = _filters) do
    remaining_query
    |> order_by([p], [desc: p.created_at])
    |> limit(^per_page)
    |> Repo.all
    |> post_preloads(current_user)
    |> filter_blocked(current_user)
  end

  defp get_last_post_created_at([]), do: nil
  defp get_last_post_created_at(posts) do
    List.last(posts).created_at
  end

  def count_and_pages_calc(query, per_page) do
    count = Repo.aggregate(query, :count, :id)
    {count, round(Float.ceil(count / per_page))}
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
    measure_segment {:db, "Ecto.PostAssetAndAuthorPreload"} do
      post_or_posts
      |> Repo.preload([assets: [], author: &Network.users(&1, current_user)])
      |> filter_assets
    end
  end

  defp filter_assets(nil), do: nil
  defp filter_assets([]), do: []
  defp filter_assets(%Post{} = post), do: Post.filter_assets(post)
  defp filter_assets(posts) do
    Enum.map(posts, &filter_assets/1)
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

    measure_segment {:db, "Ecto.CurrentUserPostRelationships"} do
      Repo.preload(post_or_posts, [
        repost_from_current_user: current_user_repost_query,
        love_from_current_user:   current_user_love_query,
        watch_from_current_user:  current_user_watch_query,
      ])
    end
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
    Map.put(post, :assets, Enum.map(assets, &Asset.build_attachment/1))
  end
  defp build_image_structs(%Post{} = post), do: post
  defp build_image_structs(nil), do: nil
  defp build_image_structs(posts) when is_list(posts) do
    measure_segment {__MODULE__, "build_image_structs"} do
      Enum.map(posts, &build_image_structs/1)
    end
  end
end
