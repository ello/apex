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
      render(conn, user: user)
    else
      send_resp(conn, 404, "")
    end
  end

  defp can_view_user?(%{assigns: %{current_user: current_user}},
                      %{locked_at: nil} = user) do
    not user.id in current_user.all_blocked_ids
  end
  defp can_view_user?(_, %{is_public: false}), do: false
  defp can_view_user?(_, %{locked_at: nil}), do: true
  defp can_view_user?(_, _), do: false
end
