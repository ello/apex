defmodule Ello.V2.UserPostController do
  import Plug.Conn
  use Ello.V2.Web, :controller
  alias Ello.Core.Content
  alias Ello.Core.Network
  alias Ello.V2.PostView

  @doc """
  GET /v2/users/:id/posts, GET /v2/users/~:username/posts

  Render posts written by a user
  """
  def index(conn, %{"user_id" => id_or_username} = params) do
    user = Network.user(id_or_username, current_user(conn), false)
    if can_view_user?(conn, user) do
      posts_page = fetch_posts_page(conn, user, params)

      conn
      |> track_post_view(posts_page.posts, stream_kind: "user", stream_id: user.id)
      |> add_pagination_headers("/users/#{user.id}/posts", posts_page)
      |> api_render_if_stale(PostView, :index, data: posts_page.posts)
    else
      send_resp(conn, 404, "")
    end
  end

  defp fetch_posts_page(conn, user, params) do
    Content.posts_by_user(user.id,
      current_user: conn.assigns[:current_user],
      allow_nsfw: conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      per_page: params["per_page"],
      before: params["before"]
    )
  end
end
