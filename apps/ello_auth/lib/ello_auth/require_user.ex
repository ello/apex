defmodule Ello.Auth.RequireUser do
  @moduledoc """
  A plug to require a user for a plug/router/endpoint.

  To require only a public token see Ello.Auth.RequireToken.

  If a user is present it will be assigned to `:current_user`.

  To use drop in any controller, router, endpoint or other plug.

      plug Ello.Auth.RequireToken
      plug Ello.Auth.RequireUser

  Everything after the call will only be hit if a user is present.
  """

  use Plug.Builder
  plug :require_user

  def require_user(%{assigns: %{current_user: user}} = conn, _)
    when not is_nil(user),
    do: conn
  def require_user(conn, _), do: halt send_resp(conn, 401, "Please sign in.")
end
