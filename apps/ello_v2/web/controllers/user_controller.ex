defmodule Ello.V2.UserController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Network
  alias Ello.V2.UserView
  alias Ello.Search.UsersIndex

  plug Ello.Auth.RequireUser, "before autocomplete" when action in [:autocomplete]

  @doc """
  GET /v2/users/:id, GET /v2/users/~:username

  Render a single user by id or username
  """
  def show(conn, %{"id" => id_or_username}) do
    user = Network.user(id_or_username, current_user(conn))
    if can_view_user?(conn, user) do
      api_render_if_stale(conn, data: user)
    else
      send_resp(conn, 404, "")
    end
  end

  def autocomplete(conn, %{"username" => username}) do
    users = UsersIndex.username_search(username, %{current_user: current_user(conn)}).body["hits"]["hits"]
            |> Enum.map(&(&1["_id"]))
            |> Network.users

    api_render(conn, UserView, "autocomplete.json", data: users)
  end
end
