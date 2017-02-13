defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    UserView,
  }
  alias Ello.V2.Util
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
    %{
      posts: render_one(post, __MODULE__, "post.json", conn: conn),
      linked: %{
        users: render_many([post.author], UserView, "user.json", conn: conn)
      }
    }
  end
  #TODO:
  #      :meta_attributes,
  #
  #      :content_warning,
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
      links: links(post, conn),
      views_count_rounded: Util.number_to_human(post.views_count),
      reposted: reposted(post.repost_from_current_user),
      loved: loved(post.love_from_current_user),
      watched: watched(post.watch_from_current_user),
    })
  end

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
    }
  end

  defp reposted(%Post{}), do: true
  defp reposted(_), do: false

  defp loved(%Love{deleted: deleted}), do: !deleted
  defp loved(_), do: false

  defp watched(%Watch{}), do: true
  defp watched(_), do: false
end
