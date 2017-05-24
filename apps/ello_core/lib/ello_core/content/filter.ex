defmodule Ello.Core.Content.Filter do
  import Ecto.Query
  alias Ello.Core.Content.Post

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
    |> filter_banned
    |> filter_private(options)
  end

  @doc """
  Filters out posts/reposts by users current_user has blocked

  This turns out to be more effective to do in elixir then ecto, so this must
  be called on a list of posts.
  """
  def post_list(list, options) do
    filter_blocked(list, options)
  end

  defp filter_nsfw(query, %{allow_nsfw: true}), do: query
  defp filter_nsfw(query, _), do: where(query, [p], not p.is_adult_content)

  defp filter_nudity(query, %{allow_nudity: true}), do: query
  defp filter_nudity(query, _), do: where(query, [p], not p.has_nudity)

  defp filter_banned(query) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], is_nil(a.locked_at) and is_nil(rpa.locked_at))
  end

  defp filter_private(query, %{current_user: nil}) do
    query
    |> join(:inner, [p], a in assoc(p, :author))
    |> join(:left, [p, a], rp in assoc(p, :reposted_source))
    |> join(:left, [p, a, rp], rpa in assoc(rp, :author))
    |> where([p, a, rp, rpa], a.is_public and (is_nil(rpa.is_public) or rpa.is_public))
  end
  defp filter_private(query, _), do: query


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
end
