defmodule Ello.Serve.Webapp.UserController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.{Network, Content}

  def show(conn, %{"username" => username}) do
    case Network.user(%{id_or_username: "~" <> username, current_user: nil}) do
      nil ->  send_resp(conn, 404, "")
      user ->
        render_html(conn, %{
          user:       user,
          posts_page: fn -> posts_page(conn, user) end,
        })
    end
  end

  defp posts_page(conn, user) do
    Content.posts_page(standard_params(conn, %{
      user_id: user.id,
      default: %{per_page: 10}
    }))
  end
end
