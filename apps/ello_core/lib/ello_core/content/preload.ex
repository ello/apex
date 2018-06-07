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

  @post_default_preloads %{
    assets: %{},
    current_user_state: %{},
    categories: %{},
    artist_invite_submission: %{artist_invite: %{}},
    author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
    post_stats: %{},
    reposted_source: %{
      assets: %{},
      current_user_state: %{},
      categories: %{},
      artist_invite_submission: %{artist_invite: %{}},
      author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
      post_stats: %{},
    }
  }
  def post_default_preloads, do: @post_default_preloads

  @comment_default_preloads %{
    assets: %{},
    parent_post: %{},
    author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
  }

  @love_default_preloads %{
    post: %{},
    user: %{},
  }

  @doc "Accepts a list of posts and preloads all related resources."
  def post_list(nil, _), do: nil
  def post_list([], _), do: []
  def post_list(post_or_posts, %{preloads: %{}} = options) do
    post_or_posts
    |> post_and_repost_preloads(options)
    |> prefetch_reposted_source(options)
  end
  def post_list(post_or_posts, options) do
    post_list(post_or_posts, Map.put(options, :preloads, @post_default_preloads))
  end

  def comment_list(nil, _), do: nil
  def comment_list([], _), do: []
  def comment_list(comments, %{preloads: %{}} = options) do
    comments
    |> prefetch_ecto_preloads(options)
    |> prefetch_parent_post(options)
    |> build_image_structs
  end
  def comment_list(comments, options) do
    comment_list(comments, Map.put(options, :preloads, @comment_default_preloads))
  end

  def love_list(nil, _), do: nil
  def love_list([], _), do: []
  def love_list(loves, %{preloads: %{}} = options) do
    loves
    |> prefetch_ecto_preloads(options, for_loves: true)
  end
  def love_list(loves, options) do
    love_list(loves, Map.put(options, :preloads, @love_default_preloads))
  end

  defp post_and_repost_preloads(posts, options) do
    posts
    |> prefetch_ecto_preloads(options)
    |> prefetch_current_user_relationships(options)
    |> prefetch_post_counts(options)
    |> build_image_structs
  end

  defp prefetch_ecto_preloads(post_or_posts, %{current_user: current_user, preloads: preloads}) do
    measure_segment {:db, "Ecto.PostPreloads"} do
      ecto_preloads = []
                      |> add_assets_preload(preloads)
                      |> add_artist_invite_submission_preload(preloads)
                      |> add_author_preload(preloads, current_user)
                      |> add_category_preload(preloads)

      post_or_posts
      |> Repo.preload(ecto_preloads)
      |> filter_assets
    end
  end
  defp prefetch_ecto_preloads(love_or_loves, %{current_user: current_user, preloads: preloads}, for_loves: true) do
    measure_segment {:db, "Ecto.LovePreloads"} do
      ecto_preloads = []
                      |> add_post_preload(preloads, current_user)
                      |> add_user_preload(preloads, current_user)
      love_or_loves
      |> Repo.preload(ecto_preloads)
      |> filter_assets
    end
  end

  defp add_assets_preload(preloads, %{assets: _}), do: [{:assets, []} | preloads]
  defp add_assets_preload(preloads, _), do: preloads

  defp add_artist_invite_submission_preload(preloads, %{artist_invite_submission: %{artist_invite: _}}),
    do: [{:artist_invite_submission, [:artist_invite]} | preloads]
  defp add_artist_invite_submission_preload(preloads, %{artist_invite_submission: _}),
    do: [{:artist_invite_submission, []} | preloads]
  defp add_artist_invite_submission_preload(preloads, _),
    do: preloads

  defp add_author_preload(preloads, %{author: author_preloads}, current_user),
    do: [{:author, &Network.users(%{ids: &1, current_user: current_user, preloads: author_preloads})} | preloads]
  defp add_author_preload(preloads, _, _), do: preloads

  defp add_user_preload(preloads, %{user: user_preloads}, current_user),
    do: [{:user, &Network.users(%{ids: &1, current_user: current_user, preloads: user_preloads})} | preloads]
  defp add_user_preload(preloads, _, _), do: preloads

  defp add_post_preload(preloads, %{post: post_preloads}, current_user),
    do: [{:post, &Content.posts(%{ids: &1, current_user: current_user, preloads: post_preloads})} | preloads]
  defp add_post_preload(preloads, _, _), do: preloads

  defp add_category_preload(preloads, %{category_posts: cp_preloads}),
    do: [{:category_posts, &Discovery.category_posts(%{ids: &1, preloads: cp_preloads})} | preloads]
  defp add_category_preload(preloads, %{categories: _}),
    do: [{:categories, &Discovery.categories(%{ids: &1})} | preloads]
  defp add_category_preload(preloads, _), do: preloads

  defp filter_assets(%Post{} = post), do: Post.filter_assets(post)
  defp filter_assets(%Love{} = love), do: Love.filter_assets(love)
  defp filter_assets(posts_or_loves) do
    Enum.map(posts_or_loves, &filter_assets/1)
  end

  defp prefetch_reposted_source(post_or_posts, %{preloads: %{reposted_source: repost_preloads}} = options) do
    options = Map.put(options, :preloads, repost_preloads)
    Repo.preload post_or_posts, reposted_source: fn(ids) ->
      Post
      |> where([p], p.id in ^ids)
      |> Repo.all
      |> repost_preloads(options)
    end
  end
  defp prefetch_reposted_source(post_or_posts, _), do: post_or_posts

  defp prefetch_parent_post(comment_or_comments, %{preloads: %{parent_post: _preloads}}) do
    Repo.preload comment_or_comments, parent_post: fn(ids) ->
      Post
      |> where([p], p.id in ^ids)
      |> Repo.all
    end
  end
  defp prefetch_parent_post(comment_or_comments, _), do: comment_or_comments

  defp repost_preloads(reposts, options) do
    reposts
    |> post_and_repost_preloads(options)
    |> Enum.map(&(nilify_reposted_source(&1)))
  end

  defp nilify_reposted_source(repost) do
    Map.put(repost, :reposted_source, nil)
  end

  defp prefetch_current_user_relationships(post_or_posts, %{current_user: %{id: id}, preloads: %{current_user_state: _}}) do
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
  defp prefetch_current_user_relationships(post_or_posts, _),
    do: post_or_posts

  defp prefetch_post_counts(%Post{} = post, options),
    do: hd(prefetch_post_counts([post], options))
  defp prefetch_post_counts(posts, %{preloads: %{post_stats: _stat_preloads}}) do
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
  defp prefetch_post_counts(posts, _), do: posts

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
