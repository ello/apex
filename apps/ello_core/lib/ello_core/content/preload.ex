defmodule Ello.Core.Content.Preload do
  import Ecto.Query
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Core.{
    Discovery,
    Content,
    Network,
    Repo,
    Redis,
  }
  alias Content.{
    Post,
    Love,
    Watch,
    Asset,
  }

  @doc "Accepts a list of posts and preloads all related resources."
  def post_list(nil, _), do: nil
  def post_list([], _), do: []
  def post_list(post_or_posts, options) do
    post_or_posts
    |> post_and_repost_preloads(options)
    |> prefetch_reposted_source(options)
  end

  def comment_list(nil, _), do: nil
  def comment_list([], _), do: []
  def comment_list(comments, options) do
    comments
    |> prefetch_assets_and_author(options)
    |> build_image_structs
  end

  def loves([], _), do: []
  def loves(loves, options) do
    Repo.preload(loves, [
      user: &Network.users(Map.put(options, :ids, &1)),
      post: &Content.posts(Map.put(options, :ids, &1)),
    ])
  end

  defp post_and_repost_preloads(posts, options) do
    posts
    |> prefetch_categories
    |> prefetch_assets_and_author(options)
    |> prefetch_current_user_relationships(options)
    |> prefetch_post_counts
    |> build_image_structs
  end

  defp prefetch_assets_and_author(post_or_posts, %{current_user: current_user}) do
    measure_segment {:db, "Ecto.PostAssetAndAuthorPreload"} do
      post_or_posts
      |> Repo.preload([assets: [], artist_invite_submission: [], author: &Network.users(%{ids: &1, current_user: current_user})])
      |> filter_assets
    end
  end

  defp filter_assets(%Post{} = post), do: Post.filter_assets(post)
  defp filter_assets(posts) do
    Enum.map(posts, &filter_assets/1)
  end

  defp prefetch_reposted_source(post_or_posts, options) do
    Repo.preload post_or_posts, reposted_source: fn(ids) ->
      Post
      |> where([p], p.id in ^ids)
      |> Repo.all
      |> repost_preloads(options)
    end
  end

  defp repost_preloads(reposts, options) do
    reposts
    |> post_and_repost_preloads(options)
    |> Enum.map(&(nilify_reposted_source(&1)))
  end

  defp nilify_reposted_source(repost) do
    Map.put(repost, :reposted_source, nil)
  end

  defp prefetch_current_user_relationships(post_or_posts, %{current_user: nil}),
    do: post_or_posts
  defp prefetch_current_user_relationships(post_or_posts, %{current_user: %{id: id}}) do
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
  defp build_image_structs(posts) when is_list(posts) do
    measure_segment {__MODULE__, "build_image_structs"} do
      Enum.map(posts, &build_image_structs/1)
    end
  end
end
