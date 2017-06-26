defmodule Ello.Serve.Webapp.UserController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Network

  def show(conn, %{"username" => username}) do
    case Network.user(%{id_or_username: "~" <> username, current_user: nil}) do
      nil ->  send_resp(conn, 404, "")
      user -> render_html(conn, user: user)
    end
  end
end
