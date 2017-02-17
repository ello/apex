defmodule Ello.V2.UserController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Network

  @doc """
  GET /v2/users/:id, GET /v2/users/~:username

  Render a single user by id or username
  """
  def show(conn, %{"id" => id_or_username}) do
    user = Network.user(id_or_username, current_user(conn))
    if can_view_user?(conn, user) do
      render_if_stale(conn, user: user)
    else
      send_resp(conn, 404, "")
    end
  end

end
