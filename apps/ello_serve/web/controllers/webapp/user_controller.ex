defmodule Ello.Serve.Webapp.UserController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  plug Ello.Serve.FindUser

  def show(conn, _) do
    render_html(conn, %{
      user:       conn.assigns.user,
      posts_page: fn -> posts_page(conn, conn.assigns.user) end,
    })
  end

  defp posts_page(conn, user) do
    page = Content.posts_page(standard_params(conn, %{
      user_id: user.id,
      default: %{per_page: 10}
    }))
    track(conn, page.posts, steam_kind: "user", stream_id: user.id)
    page
  end
end
