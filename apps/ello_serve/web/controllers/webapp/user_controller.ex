defmodule Ello.Serve.Webapp.UserController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  plug Ello.Serve.FindUser

  def show(conn, _) do
    render_html(conn, %{
      user:  conn.assigns.user,
      posts: fn -> posts(conn, conn.assigns.user) end,
    })
  end

  defp posts(conn, user) do
    posts = Content.posts(standard_params(conn, %{
      user_id: user.id,
      default: %{per_page: 10},
    }))
    track(conn, posts, steam_kind: "user", stream_id: user.id)
    posts
  end
end
