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
    user = Network.user(%{
      id_or_username: id_or_username,
      current_user:   current_user(conn),
      preload:        false
    })
    if can_view_user?(conn, user) do
      posts = fetch_posts(conn, user)

      conn
      |> track_post_view(posts, stream_kind: "user", stream_id: user.id)
      |> add_pagination_headers("/users/#{user.id}/posts", posts)
      |> api_render_if_stale(PostView, :index, data: posts)
    else
      send_resp(conn, 404, "")
    end
  end

  @doc """
  GET /v2/profile/posts

  Render posts written by the current user.
  """
  def profile(conn, _) do
    case current_user(conn) do
      nil  -> send_resp(conn, 401, "")
      user ->
        posts = fetch_posts(conn, user)

        conn
        |> track_post_view(posts, stream_kind: "user", stream_id: user.id)
        |> add_pagination_headers("/users/#{user.id}/posts", posts)
        |> api_render_if_stale(PostView, :index, data: posts)
    end
  end

  defp fetch_posts(conn, user) do
    Content.posts(standard_params(conn, %{
      user_id: user.id,
      default: %{per_page: 10},
    }))
  end
end
