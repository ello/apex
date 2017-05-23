defmodule Ello.Core.Content do
  import NewRelicPhoenix, only: [measure_segment: 2]
  import Ecto.Query
  alias Ello.Core.Repo
  alias __MODULE__.{
    PostsPage,
    Filter,
    Preload,
    Post,
  }

  @moduledoc """
  Responsible for retrieving and loading posts, comments, and related assets.

  Handles database queryies, preloading reposts, and fetching cached values.
  """

  @typedoc """
  All Ello.Core.Content public functions expect to receive a map of options.
  Those options should always include `current_user`, `allow_nsfw`, and
  `allow_nudity`. Any extra options should be included in the same map.
  """
  @type options :: %{
    required(:current_user) => User.t | nil,
    required(:allow_nsfw)   => boolean,
    required(:allow_nudity) => boolean,
    optional(:ids)          => [integer],
    optional(:related_to)   => Post.t,
    optional(any)           => any
  }

  @doc """
  Get a post by id or token.

  Includes postgres info and bulk fetched redis info.

  If the current_user is passed in the reposted/wathched/loved relationship will
  also be included, and the post will be filtered based on blocked users, nsfw
  and nudity content visibility, and posts by banned users.  If no user is
  present, posts by private users will not be included.
  """
  @spec post(options) :: Post.t | nil
  def post(%{id_or_token: "~" <> token} = options) do
    Post
    |> Filter.post_query(options)
    |> Repo.get_by(token: token)
    |> Preload.post_list(options)
    |> Filter.post_list(options)
  end
  def post(%{id_or_token: id} = options) do
    Post
    |> Filter.post_query(options)
    |> Repo.get(id)
    |> Preload.post_list(options)
    |> Filter.post_list(options)
  end

  @doc """
  Get posts filtered for user/client and with all preloads.

  Uses different algorithms to find the posts based on the options passed in.
    * ids - Finds by post ids, posts returned in same order as ids.
    * tokens - Finds by post tokens, posts returned in same order as tokens.
    * related_to - Finds posts related to the post passed in.

  Posts are returned in the order the ids are given.
  """
  def posts(%{ids: ids} = options) do
    Post
    |> where([p], p.id in ^ids)
    |> Filter.post_query(options)
    |> Repo.all
    |> Preload.post_list(options)
    |> Filter.post_list(options)
    |> post_sorting(:id, ids)
  end
  def posts(%{tokens: tokens} = options) do
    Post
    |> where([p], p.token in ^tokens)
    |> Filter.post_query(options)
    |> Repo.all
    |> Preload.post_list(options)
    |> Filter.post_list(options)
    |> post_sorting(:tokens, tokens)
  end
  def posts(%{related_to: %Post{} = related_to, per_page: per_page} = options) do
    %{id: related_id, author_id: author_id} = related_to
    Post
    |> Filter.post_query(options)
    |> where([p], p.author_id == ^author_id)
    |> where([p], p.id != ^related_id)
    |> where([p], is_nil(p.parent_post_id))
    |> order_by(fragment("random()"))
    |> limit(^per_page)
    |> Repo.all
    |> Preload.post_list(options)
    |> Filter.post_list(options)
  end

  defp post_sorting(posts, field, values) do
    measure_segment {__MODULE__, "post_sorting"} do
      mapped = Enum.group_by(posts, &Map.get(&1, field))
      values
      |> Enum.uniq
      |> Enum.flat_map(&(mapped[&1] || []))
    end
  end

  @spec posts_page(options) :: PostsPage.t
  def posts_page(%{} = options) do
    per_page = parse_per_page(options[:per_page])
    before = parse_before(options[:before])

    total_query = total_posts_by_user_query(options)
    remaining_query = remaining_posts_by_user_query(total_query, before)

    measure_segment {:db, "Ecto.UserPostsQuery"} do
      posts_task = Task.async(__MODULE__, :page_of_posts_by_user_query, [remaining_query, per_page, options])
      total_count_task = Task.async(__MODULE__, :count_and_pages_calc, [total_query, per_page])
      remaining_count_task = Task.async(__MODULE__, :count_and_pages_calc, [remaining_query, per_page])

      query_wait_time = Application.get_env(:ello_core, :user_post_query_timeout)

      posts = Task.await(posts_task, query_wait_time)
      {total_count, total_pages} = Task.await(total_count_task, query_wait_time)
      {_, remaining_pages} = Task.await(remaining_count_task, query_wait_time)
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

  defp total_posts_by_user_query(%{user_id: user_id} = options) do
    Post
    |> Filter.post_query(options)
    |> where([p], p.author_id == ^user_id and is_nil(p.parent_post_id))
  end

  defp remaining_posts_by_user_query(total_query, nil), do: total_query
  defp remaining_posts_by_user_query(total_query, date) do
    where(total_query, [p], p.created_at < ^date)
  end

  def page_of_posts_by_user_query(remaining_query, per_page, options) do
    remaining_query
    |> order_by([p], [desc: p.created_at])
    |> limit(^per_page)
    |> Repo.all
    |> Preload.post_list(options)
    |> Filter.post_list(options)
  end

  defp get_last_post_created_at([]), do: nil
  defp get_last_post_created_at(posts) do
    List.last(posts).created_at
  end

  def count_and_pages_calc(query, per_page) do
    count = Repo.aggregate(query, :count, :id)
    {count, round(Float.ceil(count / per_page))}
  end
end
