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
  }

  @spec post(id_or_slug :: String.t | integer, current_user :: User.t | nil) :: Post.t
  def post(id_or_slug, current_user \\ nil)
  def post("~" <> slug, current_user) do
    Post
    |> Repo.get_by(token: slug)
    |> post_preloads(current_user)
  end
  def post(id, current_user) do
    Post
    |> Repo.get(id)
    |> post_preloads(current_user)
  end

  defp post_preloads(post_or_posts, current_user) do
    post_or_posts
    |> prefetch_author(current_user)
    |> prefetch_current_user_repost(current_user)
    |> prefetch_current_user_love(current_user)
    |> prefetch_post_counts
  end

  defp prefetch_author([], _), do: []
  defp prefetch_author(post_or_posts, current_user) do
    Repo.preload(post_or_posts, author: &Network.users(&1, current_user))
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
