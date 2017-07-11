defmodule Ello.Serve.Webapp.UserController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.{Network, Content}

  def show(conn, %{"username" => username}) do
    user = Network.user(%{id_or_username: "~" <> username, current_user: nil})
    case {user, conn.assigns.logged_in_user?} do
      {nil, _}                     -> send_resp(conn, 404, "")
      {%{is_public: false}, false} -> send_resp(conn, 404, "")
      {user, _} ->
        render_html(conn, %{
          user:       user,
          posts_page: fn -> posts_page(conn, user) end,
        })
    end
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
