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
    user = Network.user(id_or_username, current_user(conn))
    if can_view_user?(conn, user) do
      user_posts(conn, user, params)
    else
      send_resp(conn, 404, "")
    end
  end

  defp user_posts(conn, user, params) do
    %{posts: posts} = posts_page = Content.posts_by_user(user.id,
      current_user: conn.assigns[:current_user],
      allow_nsfw: conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      per_page: params["per_page"], before: params["before"])
    conn = add_page_headers(conn, posts_page)
    render(conn, PostView, :index, posts: posts)
  end

  defp add_page_headers(conn, %{
    total_pages: total_pages,
    total_count: total_count,
    total_pages_remaining: total_pages_remaining} = _posts_page
  ) do
    conn
    |> put_resp_header("x-total-pages", "#{total_pages}")
    |> put_resp_header("x-total-count", "#{total_count}")
    |> put_resp_header("x-total-pages-remaining", "#{total_pages_remaining}")
  end

end
