defmodule Ello.V2.PostView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    UserView,
  }

  @attributes [
   :token,
   :is_adult_content,
   :body,
   :created_at,
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

  # attributes :comments_count,
  #            :loves_count,
  #            :reposts_count,
  #            :views_count,
  #            :views_count_rounded,
  #            group: :counts

  # # current user state
  # attributes :loved,
  #            :reposted,
  #            :watching,
  #            group: :user_state

  # # SEO meta tag attributes
  # attributes :meta_attributes,
  #            group: :meta_attributes
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
