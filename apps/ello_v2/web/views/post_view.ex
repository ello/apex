defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    UserView,
    AssetView,
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
             |> render_linked_users(post, conn)
             |> render_linked_posts(post, conn)
             |> render_linked_assets(post, conn)
    %{
      posts: render_one(post, __MODULE__, "post.json", conn: conn),
      linked: linked,
    }
  end

  #TODO:
  #      :meta_attributes
  def render("post.json", %{post: post, conn: conn}) do
    post
    |> Map.take(@attributes)
    |> Map.merge(reposted_attributes(post.reposted_source))
    |> Map.merge(%{
      id: "#{post.id}",
      href: "/api/v2/posts/#{post.id}",
      summary: post.rendered_summary,
      content: post.rendered_content,
      author_id: "#{post.author.id}",
      views_count_rounded: Util.number_to_human(post.views_count),
      reposted: reposted(post.repost_from_current_user),
      loved: loved(post.love_from_current_user),
      watched: watched(post.watch_from_current_user),
      content_warning: content_warning(post, conn),
      links: links(post, conn),
    })
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

  def render_linked_assets(linked, %{assets: assets} = post, conn) when is_list(assets) do
    Map.put(linked, :assets, render_many(assets, AssetView, "asset.json", conn: conn))
  end
  def render_linked_assets(linked, %{assets: assets, reposted_source: %Post{} = repost} = post, conn) when is_list(assets) do
    Map.put(linked, :assets, render_many(assets ++ repost.assets, AssetView, "asset.json", conn: conn))
  end
  def render_linked_assets(linked, _, _), do: linked

  defp reposted_attributes(nil),
    do: %{repost_content: nil, repost_id: nil}
  defp reposted_attributes(repost) do
    %{
      repost_content: repost.rendered_content,
      repost_id: repost.id,
    }
  end

  defp links(post, _conn) do
    %{
      author: %{
        id: "#{post.author.id}",
        type: "users",
        href: "/api/v2/users/#{post.author.id}",
      },
      assets:  Enum.map(post.assets, &("#{&1.id}")),
    }
  end

  defp reposted(%Post{}), do: true
  defp reposted(_), do: false

  defp loved(%Love{deleted: deleted}), do: !deleted
  defp loved(_), do: false

  defp watched(%Watch{}), do: true
  defp watched(_), do: false

  defp content_warning(nil, _), do: nil
  defp content_warning([], _), do: []
  defp content_warning(post_or_posts, %{assigns: %{current_user: nil}}), do: post_or_posts
  defp content_warning(%Post{} = post, %{assigns: %{current_user: current_user}}) do
    include_nsfw_warning = post.is_adult_content && !current_user.settings.views_adult_content
    include_third_party_warning = has_embedded_media(post) && current_user.settings.has_ad_notifications_enabled

    case {include_nsfw_warning, include_third_party_warning} do
      {true, true} -> "NSFW. May contain 3rd party ads."
      {false, true} -> "May contain 3rd party ads."
      {true, false} -> "NSFW."
      _ -> ""
    end
  end
  defp content_warning(posts, %{assigns: %{current_user: current_user}}) do
    Enum.map(posts, &content_warning(&1, current_user))
  end

  defp has_embedded_media(%{} = post) do
    Enum.any?(post.body, fn(body) ->
      body["kind"] == "embed"
    end) || has_embedded_media(post.reposted_source)
  end
  defp has_embedded_media(_), do: false
end
