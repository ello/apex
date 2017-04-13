defmodule Ello.V2.UserController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Network
  alias Ello.V2.UserView
  alias Ello.Search.UserSearch

  plug Ello.Auth.RequireUser when action in [:autocomplete]

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

  @doc """
  GET /v2/users

  Renders a list of relevant results from user search
  """
  def index(conn, %{"terms" => terms}) do
    users = UserSearch.user_search(terms, %{current_user: current_user(conn), allow_nsfw: conn.assigns[:allow_nsfw], allow_nudity: conn.assigns[:allow_nudity]})
    api_render_if_stale(conn, UserView, "index.json", data: users)
  end

  @doc """
  GET /v2/users/autocomplete

  Renders a list of relevant results from username search
  """
  def autocomplete(conn, %{"terms" => username}) do
    users = UserSearch.username_search(username, %{current_user: current_user(conn)})
    api_render(conn, UserView, "autocomplete.json", data: users)
  end
end
