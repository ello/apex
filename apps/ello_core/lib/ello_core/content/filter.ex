defmodule Ello.Core.Content.Filter do
  import Ecto.Query
  alias Ello.Core.Content.Post
  alias Ello.Core.Redis

  @minimum_cred (Application.get_env(:ello_core, :minimum_cred) || 100)

  @doc """
  Takes a post query and adds filtering clauses to it.

  Currently filters:
    * nsfw posts/reposts if allow_nsfw != true
    * nudity posts/reposts if allow_nudity != true
    * private posts/reposts if there is no current_user
    * banned users' posts/reposts

  See post_list/1 for filtering blocked users/posts.
  """
  def post_query(query, options) do
    query
    |> filter_nsfw(options)
    |> filter_nudity(options)
    |> filter_banned(options)
    |> filter_private(options)
  end

  def comments_query(query, options) do
    query
    |> filter_banned_comments
    |> filter_private_comments(options)
  end

  @doc """
  Filters out posts/reposts by users current_user has blocked

  This turns out to be more effective to do in elixir then ecto, so this must
  be called on a list of posts.
  """
  def post_list(list, options) do
    list
    |> filter_blocked(options)
    |> filter_require_cred(options)
  end

  defp filter_nsfw(query, %{allow_nsfw: true}), do: query
  defp filter_nsfw(query, _), do: where(query, [p], not p.is_adult_content)

  defp filter_nudity(query, %{allow_nudity: true}), do: query
  defp filter_nudity(query, _), do: where(query, [p], not p.has_nudity)

  defp filter_banned(query, %{current_user: %{is_staff: true}}), do: query
  defp filter_banned(query, _) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], is_nil(a.locked_at) and is_nil(rpa.locked_at))
  end

  defp filter_banned_comments(query) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> where([p, a], is_nil(a.locked_at))
  end

  defp filter_private(query, %{current_user: nil}) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], a.is_public and (is_nil(rpa.is_public) or rpa.is_public))
  end
  defp filter_private(query, _), do: query

  defp filter_private_comments(query, %{current_user: nil}) do
    where(query, [p, a], a.is_public)
  end
  defp filter_private_comments(query, _), do: query

  defp filter_require_cred(nil, _), do: nil
  defp filter_require_cred([], _), do: []
  defp filter_require_cred(%Post{} = post, %{require_cred: true}),
    do: if author_has_cred(post), do: post, else: nil
  defp filter_require_cred(posts, %{require_cred: true}) do
    Enum.filter(posts, &author_has_cred(&1))
  end
  defp filter_require_cred(posts, _), do: posts

  defp author_has_cred(%{author_id: author_id}) do
    key = "user:#{author_id}:total_post_views_counter"
    redis_counts = Redis.command(["GET" | [key]], name: :user_counts)
    try do
      case redis_counts do
        {:ok, nil} -> false
        {:ok, ""} -> false
        {:ok, user_counts} ->
          String.to_integer(user_counts) > @minimum_cred
        _ -> true
      end
    rescue _ in ArgumentError ->
      true
    end
  end

  defp filter_blocked(nil, _), do: nil
  defp filter_blocked([], _), do: []
  defp filter_blocked(post_or_posts, %{current_user: nil}), do: post_or_posts
  defp filter_blocked(post_or_posts, %{current_user: %{all_blocked_ids: %{map: blocked}}})
       when map_size(blocked) == 0,
       do: post_or_posts
  defp filter_blocked(%Post{} = post, %{current_user: %{all_blocked_ids: blocked}}),
    do: if is_blocked(post, blocked), do: nil, else: post
  defp filter_blocked(posts, %{current_user: %{all_blocked_ids: blocked}}),
    do: Enum.reject(posts, &is_blocked(&1, blocked))

  defp is_blocked(%{reposted_source: %{author_id: rp_id}, author_id: id}, blocked),
    do: id in blocked || rp_id in blocked
  defp is_blocked(%{author_id: id}, blocked),
    do: id in blocked

  @doc """
  Takes a loves query and adds filtering clauses to it.

  Currently filters:
    * nsfw posts/reposts if allow_nsfw != true
    * nudity posts/reposts if allow_nudity != true
    * private posts/reposts if there is no current_user
    * banned users' posts/reposts

  See post_list/1 for filtering blocked users/posts.
  """
  def loves_query(query, options) do
    query
    |> loves_filter_joins
    |> filter_banned_loves
    |> filter_private_loves(options)
    |> filter_nsfw_loves(options)
    |> filter_nudity_loves(options)
  end

  defp filter_banned_loves(query) do
    where(query, [l, p, a, rp, rpa], is_nil(a.locked_at) and is_nil(rpa.locked_at))
  end

  defp loves_filter_joins(query) do
    query
    |> join(:inner, [l], p in assoc(l, :post))
    |> join(:inner, [l, p], a in assoc(p, :author))
    |> join(:left, [l, p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [l, p, a, rp], rpa in assoc(rp, :author))
  end

  defp filter_private_loves(query, %{current_user: nil}) do
    where(query, [l, p, a, rp, rpa], a.is_public and (is_nil(rpa.is_public) or rpa.is_public))
  end
  defp filter_private_loves(query, _), do: query

  defp filter_nsfw_loves(query, %{allow_nsfw: true}), do: query
  defp filter_nsfw_loves(query, _), do: where(query, [l, p], not p.is_adult_content)
  defp filter_nudity_loves(query, %{allow_nudity: true}), do: query
  defp filter_nudity_loves(query, _), do: where(query, [l, p], not p.has_nudity)
end
