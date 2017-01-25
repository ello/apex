defmodule Ello.V2.UserController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Network

  @doc """
  GET /v2/users/:id, GET /v2/users/~:username

  Render a single user by id or username
  """
  def show(conn, %{"id" => id_or_username}) do
    render(conn, user: Network.user(id_or_username, current_user(conn)))
  end
end
