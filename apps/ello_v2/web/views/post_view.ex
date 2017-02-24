defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{
    CategoryView,
    UserView,
    AssetView,
    PostMetaAttributesView,
  }
  alias Ello.V2.Util
  alias Ello.Core.Network.{User}
  alias Ello.Core.Content.{Post,Love,Watch}

  @doc "Render a list of posts and relations for /api/v2/user/:id/posts"
  def render("index.json", %{posts: posts} = opts) do
    users     = post_users(posts)
    assets    = post_assets(posts)
    reposts   = Enum.map(posts, &(&1.reposted_source))
    all_posts = post_and_reposts(posts)
    categories = Enum.flat_map(all_posts ++ users, &(&1.categories))

    json_response()
    |> render_resource(:posts, posts, __MODULE__, opts)
    |> include_linked(:categories, categories, CategoryView, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:posts, reposts, __MODULE__, opts)
    |> include_linked(:assets, assets, AssetView, opts)
  end

  @doc "Render a post and relations for /api/v2/posts/:id"
  def render("show.json", %{post: post} = opts) do
    users      = post_users(post, post.reposted_source)
    assets     = post_assets(post, post.reposted_source)
    posts      = post_and_reposts(post, post.reposted_source)
    categories = Enum.flat_map(posts ++ users, &(&1.categories))

    json_response()
    |> render_resource(:posts, post, __MODULE__, Map.merge(opts, %{meta: true}))
    |> include_linked(:categories, categories, CategoryView, opts)
    |> include_linked(:users, users, UserView, opts)
    |> include_linked(:posts, [post.reposted_source], __MODULE__, opts)
    |> include_linked(:assets, assets, AssetView, opts)
  end

  @doc "Render a single post as included in other reponses"
  def render("post.json", %{post: post} = opts) do
    post
    |> render_self(__MODULE__, opts)
    |> add_meta(post, opts[:meta])
  end

  def attributes, do: [
    :token,
    :is_adult_content,
    :body,
    :created_at,
  ]

  def computed_attributes, do: [
    :href,
    :summary,
    :content,
    :author_id,
    :views_count_rounded,
    :reposted,
    :loved,
    :watching,
    :content_warning,
    :repost_content,
    :repost_id,
    :loves_count,
    :comments_count,
    :reposts_count,
    :views_count,
  ]

  defp post_users(posts) when is_list(posts), do: Enum.flat_map(posts, &(post_users(&1, &1.reposted_source)))
  defp post_users(%{author: %User{} = a}, %{author: %User{} = ra}), do: [a, ra]
  defp post_users(%{author: %User{} = author}, _), do: [author]

  defp post_assets(posts) when is_list(posts), do: Enum.flat_map(posts, &(post_assets(&1, &1.reposted_source)))
  defp post_assets(%{assets: a}, %Post{assets: ra}), do: a ++ ra
  defp post_assets(%{assets: assets}, _), do: assets

  defp post_and_reposts(posts) when is_list(posts), do: Enum.flat_map(posts, &(post_and_reposts(&1, &1.reposted_source)))
  defp post_and_reposts(post, %Post{} = repost), do: [post, repost]
  defp post_and_reposts(post, _), do: [post]

  def href(%{id: id}, _), do: "/api/v2/posts/#{id}"

  def summary(%{reposted_source: %{rendered_summary: summary}}, _), do: summary
  def summary(%{rendered_summary: post_summary}, _), do: post_summary

  def content(%{rendered_content: content}, _), do: content

  def repost_content(%{reposted_source: %{rendered_content: c}}, _), do: c
  def repost_content(_, _), do: []

  def repost_id(%{reposted_source: %{id: id}}, _), do: "#{id}"
  def repost_id(_, _), do: ""

  def author_id(post, _), do: "#{post.author.id}"

  def views_count_rounded(post, _), do: Util.number_to_human(post.views_count)

  def links(%{reposted_source: %Post{} = reposted} = post, conn) do
    post
    |> Map.put(:reposted_source, nil)
    |> links(conn)
    |> Map.merge(%{
      repost_author: %{
        href: "/api/v2/users/#{reposted.author.id}",
        id: "#{reposted.author.id}",
        type: "users",
      },
      reposted_source: %{
        href: "/api/v2/posts/#{reposted.id}",
        id: "#{reposted.id}",
        type: "posts",
      }
    })
  end
  def links(post, _conn) do
    %{
      categories: Enum.map(post.categories, &("#{&1.id}")),
      author: %{
        id: "#{post.author.id}",
        type: "users",
        href: "/api/v2/users/#{post.author.id}",
      },
      assets: Enum.map(post.assets, &("#{&1.id}")),
    }
  end

  def reposted(%{repost_from_current_user: %Post{}}, _), do: true
  def reposted(_, _), do: false

  def loved(%{love_from_current_user: %Love{deleted: deleted}}, _), do: !deleted
  def loved(_, _), do: false

  def watching(%{watch_from_current_user: %Watch{}}, _), do: true
  def watching(_, _), do: false

  def loves_count(%{reposted_source: %{loves_count: count}}, _), do: count
  def loves_count(%{loves_count: count}, _), do: count

  def comments_count(%{reposted_source: %{comments_count: count}}, _), do: count
  def comments_count(%{comments_count: count}, _), do: count

  def reposts_count(%{reposted_source: %{reposts_count: count}}, _), do: count
  def reposts_count(%{reposts_count: count}, _), do: count

  def views_count(%{reposted_source: %{views_count: count}}, _), do: count
  def views_count(%{views_count: count}, _), do: count

  def content_warning(%Post{} = post, %{assigns: %{current_user: current_user}}) do
    include_third_party_warning = has_embedded_media(post) &&
      current_user.settings.has_ad_notifications_enabled

    case include_third_party_warning do
      true -> "May contain 3rd party ads."
      _ -> ""
    end
  end
  def content_warning(_post, _), do: ""

  defp has_embedded_media(%{} = post) do
    Enum.any?(post.body, fn(body) ->
      body["kind"] == "embed"
    end) || has_embedded_media(post.reposted_source)
  end
  defp has_embedded_media(_), do: false

  defp add_meta(resp, post, true) do
    Map.put(resp, :meta_attributes, render(PostMetaAttributesView, "post.json", post: post))
  end
  defp add_meta(resp, _, _), do: resp
end
