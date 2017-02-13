defmodule Ello.Core.Content do
  import Ecto.Query
  alias Ello.Core.{
    Repo,
    Redis,
    Network,
  }
  alias __MODULE__.{
    Post,
    Love,
    Watch,
  }

  @spec post(id_or_slug :: String.t | integer, current_user :: User.t | nil, allow_nsfw :: boolean, allow_nudity :: boolean) :: Post.t
  def post(id_or_slug, current_user \\ nil, allow_nsfw, allow_nudity)
  def post("~" <> slug, current_user, allow_nsfw, allow_nudity) do
    Post
    |> filter_post_for_client(current_user, allow_nsfw, allow_nudity)
    |> Repo.get_by(token: slug)
    |> post_preloads(current_user, allow_nsfw, allow_nudity)
  end
  def post(id, current_user, allow_nsfw, allow_nudity) do
    Post
    |> filter_post_for_client(current_user, allow_nsfw, allow_nudity)
    |> Repo.get(id)
    |> post_preloads(current_user, allow_nsfw, allow_nudity)
  end

  defp filter_post_for_client(query, current_user, allow_nsfw, allow_nudity) do
    query
    |> filter_nsfw(allow_nsfw)
    |> filter_nudity(allow_nudity)
    |> filter_blocked(current_user)
    |> filter_banned
    |> filter_private(current_user)
  end

  defp filter_nsfw(query, true), do: query
  defp filter_nsfw(query, false), do: where(query, [p], not p.is_adult_content)

  defp filter_nudity(query, true), do: query
  defp filter_nudity(query, false), do: where(query, [p], not p.has_nudity)

  defp filter_blocked(query, nil), do: query
  defp filter_blocked(query, current_user) do
    # need:
    #   LEFT JOIN posts AS reposted ON reposted.id = posts.reposted_source_id
    #   LEFT OUTER JOIN (VALUES (ids) excluded(excluded_id) ON posts.author_id = excluded_id OR resposted.author_id = excluded_id)
    #   WHERE excluded_id IS NULL
    # ids = current_user.all_blocked_ids
    #       |> Enum.map(&("(#{&1})"))
    #       |> Enum.join(",")
    #       |> IO.inspect
    # query
    # |> join(:left, [p, rp], fragment("(VALUES (?)) excluded(excluded_id)", ^ids), excluded_id == p.author_id or excluded_id == rp.author_id)

    ids = current_user.all_blocked_ids
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], not p.author_id in ^ids and not rp.author_id in ^ids)
  end

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

  defp post_preloads(post_or_posts, current_user, allow_nsfw, allow_nudity) do
    post_or_posts
    |> prefetch_author(current_user)
    |> prefetch_reposted_source(current_user, allow_nsfw, allow_nudity)
    |> prefetch_current_user_repost(current_user)
    |> prefetch_current_user_love(current_user)
    |> prefetch_current_user_watch(current_user)
    |> prefetch_post_counts
  end

  defp prefetch_author(nil, _), do: nil
  defp prefetch_author([], _), do: []
  defp prefetch_author(post_or_posts, current_user) do
    Repo.preload(post_or_posts, author: &Network.users(&1, current_user))
  end

  defp prefetch_reposted_source(nil, _, _, _), do: nil
  defp prefetch_reposted_source([], _, _, _), do: []
  defp prefetch_reposted_source(post_or_posts, current_user, allow_nsfw, allow_nudity) do
    Repo.preload(post_or_posts, reposted_source: fn(ids) ->
      Enum.map(ids, &post(&1, current_user, allow_nsfw, allow_nudity))
      end)
  end

  defp prefetch_current_user_repost(post_or_posts, nil), do: post_or_posts
  defp prefetch_current_user_repost(post_or_posts, %{id: id}) do
    current_user_repost_query = where(Post, author_id: ^id)
    Repo.preload(post_or_posts, [repost_from_current_user: current_user_repost_query])
  end

  defp prefetch_current_user_love(post_or_posts, nil), do: post_or_posts
  defp prefetch_current_user_love(post_or_posts, %{id: id}) do
    current_user_love_query = where(Love, user_id: ^id)
    Repo.preload(post_or_posts, [love_from_current_user: current_user_love_query])
  end

  defp prefetch_current_user_watch(post_or_posts, nil), do: post_or_posts
  defp prefetch_current_user_watch(post_or_posts, %{id: id}) do
    current_user_watch_query = where(Watch, user_id: ^id)
    Repo.preload(post_or_posts, [watch_from_current_user: current_user_watch_query])
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
end
