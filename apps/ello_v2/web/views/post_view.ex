defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    CategoryView,
    UserView,
    AssetView,
    PostMetaAttributesView,
  }
  alias Ello.V2.Util
  alias Ello.Core.Network.{User}
  alias Ello.Core.Content.{Post,Love,Watch}

  @attributes [
    :token,
    :is_adult_content,
    :body,
    :created_at,
    :loves_count,
    :comments_count,
    :reposts_count,
    :views_count,
  ]

  def render("show.json", %{post: post, conn: conn}) do
    linked = %{}
             |> render_linked_categories(post, conn)
             |> render_linked_users(post, conn)
             |> render_linked_posts(post, conn)
             |> render_linked_assets(post, conn)
    %{
      posts: render_one(post, __MODULE__, "post.json", conn: conn, meta: true),
      linked: linked,
    }
  end

  def render("post.json", %{post: post, conn: conn} = opts) do
    post
    |> Map.take(@attributes)
    |> Map.merge(reposted_attributes(post.reposted_source))
    |> add_meta(post, opts[:meta])
    |> Map.merge(%{
      id: "#{post.id}",
      href: "/api/v2/posts/#{post.id}",
      summary: summary(post),
      content: post.rendered_content,
      author_id: "#{post.author.id}",
      views_count_rounded: Util.number_to_human(post.views_count),
      reposted: reposted(post.repost_from_current_user),
      loved: loved(post.love_from_current_user),
      watching: watching(post.watch_from_current_user),
      content_warning: content_warning(post, conn),
      links: links(post, conn),
    })
  end

  def render_linked_categories(linked, %{categories: []}, _conn), do: linked
  def render_linked_categories(linked, %{categories: categories}, conn) do
    Map.put(linked, :categories, render_many(categories, CategoryView, "category.json", conn: conn))
  end

  def render_linked_users(linked, %{author: %User{} = author, reposted_source: %{author: %User{} = repost_author}}, conn) do
    Map.put(linked, :users, render_many([author, repost_author], UserView, "user.json", conn: conn))
  end
  def render_linked_users(linked, %{author: %User{} = author}, conn) do
    Map.put(linked, :users, render_many([author], UserView, "user.json", conn: conn))
  end
  def render_linked_users(linked, _, _), do: linked

  def render_linked_posts(linked, %{reposted_source: %Post{} = repost}, conn) do
    Map.put(linked, :posts, render_many([repost], __MODULE__, "post.json", conn: conn))
  end
  def render_linked_posts(linked,_, _), do: linked

  def render_linked_assets(linked, %{assets: assets, reposted_source: %Post{} = repost}, conn) when is_list(assets) do
    Map.put(linked, :assets, render_many(assets ++ repost.assets, AssetView, "asset.json", conn: conn))
  end
  def render_linked_assets(linked, %{assets: assets}, conn) when is_list(assets) do
    Map.put(linked, :assets, render_many(assets, AssetView, "asset.json", conn: conn))
  end
  def render_linked_assets(linked, _, _), do: linked

  defp reposted_attributes(nil),
    do: %{repost_content: [], repost_id: ""}
  defp reposted_attributes(repost) do
    %{
      repost_content: repost.rendered_content,
      repost_id: repost.id,
    }
  end

  defp summary(%{reposted_source: %{rendered_summary: repost_summary}}),
    do: repost_summary
  defp summary(%{rendered_summary: post_summary}),
    do: post_summary

  defp links(post, _conn) do
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

  defp reposted(%Post{}), do: true
  defp reposted(_), do: false

  defp loved(%Love{deleted: deleted}), do: !deleted
  defp loved(_), do: false

  defp watching(%Watch{}), do: true
  defp watching(_), do: false

  defp content_warning(%Post{} = post, %{assigns: %{current_user: current_user}}) do
    include_third_party_warning = has_embedded_media(post) && current_user.settings.has_ad_notifications_enabled

    case include_third_party_warning do
      true -> "May contain 3rd party ads."
      _ -> ""
    end
  end
  defp content_warning(_post, _), do: ""

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
