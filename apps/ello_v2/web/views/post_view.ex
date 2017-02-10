defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    UserView,
  }
  alias Ello.V2.Util

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
  #TODO: :content_warning,
  #      :repost_content,
  #      :repost_id,
  #      :repost_path,
  #      :repost_via_id,
  #      :repost_via_path
  #      :loved,
  #      :reposted,
  #      :watching,
  #      :meta_attributes,
  def render("post.json", %{post: post, conn: conn}) do
    post
    |> Map.take(@attributes)
    |> Map.merge(
    %{
      id: "#{post.id}",
      href: "/api/v2/posts/#{post.id}",
      summary: post.rendered_summary,
      content: post.rendered_content,
      author_id: "#{post.author.id}",
      links: links(post, conn),
      views_count_rounded: Util.number_to_human(post.views_count),
    })
  end

  def links(post, _conn) do
    %{
      author: %{
        id: "#{post.author.id}",
        type: "users",
        href: "/api/v2/users/#{post.author.id}",
      },
    }
  end
end
