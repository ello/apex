defmodule Ello.Serve.FindUser do
  @moduledoc """
  A plug to find a user for a plug/router/endpoint.

  To use drop in any controller, router, endpoint or other plug.

      plug Ello.Serve.FindUser
  """
  use Plug.Builder
  alias Ello.Core.Network
  plug :find_user

  def find_user(%{params: %{"username" => username}} = conn, _) do
    user = Network.user(%{id_or_username: "~" <> username, current_user: nil})
    case {user, conn.assigns.logged_in_user?} do
      {nil, _}                     -> halt send_resp(conn, 404, "")
      {%{is_public: false}, false} -> halt send_resp(conn, 404, "")
      {user, _}                    -> assign(conn, :user, user)
    end
  end
end
