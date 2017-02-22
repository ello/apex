defmodule Ello.Auth.RequireToken do
  @moduledoc """
  A plug to require a plug/router/endpoint to be token authenticted.

  Does not require a user be present, to require a user see
  Ello.Auth.RequireUser. If a user is present it will be assigned to
  `:current_user`.

  To use drop in any controller, router, endpoint or other plug.

      plug Ello.Auth.RequireToken

  Everything after the call will require a token.
  """

  use Plug.Builder
  import Plug.Conn
  alias Ello.Auth.JWT

  plug :get_jwt
  plug :verify_jwt

  @doc "Get JWT from headers, assign to :jwt or 401"
  def get_jwt(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> jwt] -> assign(conn, :jwt, jwt)
      _                  -> halt send_resp(conn, 401, "No token provided")
    end
  end

  @doc "Verify JWT is properly signed etc, assign user if present."
  def verify_jwt(conn, _) do
    case JWT.verify(conn.assigns.jwt) do
      {:ok, payload}    -> assign_user_if_user(conn, payload)
      {:error, message} -> halt send_resp(conn, 401, message)
    end
  end

  defp assign_user_if_user(conn, %{"data" => %{"id" => id}}) do
    case load_user(id) do
      nil  -> halt send_resp(conn, 401, "Invalid user token")
      user -> assign(conn, :current_user, user)
    end
  end
  defp assign_user_if_user(conn, _), do: conn

  defp load_user(id) do
    {module, fun} = Application.get_env(:ello_auth, :user_lookup_mfa)
    apply(module, fun, [id])
  end
end
