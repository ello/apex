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
  def index(conn, %{"user_id" => id_or_username}) do
    user = Network.user(id_or_username, current_user(conn), false)
    if can_view_user?(conn, user) do
      posts_page = fetch_posts_page(conn, user)

      conn
      |> track_post_view(posts_page.posts, stream_kind: "user", stream_id: user.id)
      |> add_pagination_headers("/users/#{user.id}/posts", posts_page)
      |> api_render_if_stale(PostView, :index, data: posts_page.posts)
    else
      send_resp(conn, 404, "")
    end
  end

  defp fetch_posts_page(conn, user) do
    Content.posts_page(standard_params(conn, %{user_id: user.id}))
  end
end
