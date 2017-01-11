defmodule Ello.V2.Authenticate do
  @moduledoc """
  Responsible for ensuring http requests have a valid JWT bearer token.
  If no token is available, a 401 is returned.
  If the token is expired, not properly signed, etc a 401 is returned.
  Otherwise the `:jwt`, `:user_id` and `username` are assigned to the conn.
  """

  use Plug.Builder
  import Plug.Conn
  alias Ello.{JWT,User,Repo}

  plug :get_jwt
  plug :validate_jwt

  def get_jwt(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> jwt] -> assign(conn, :jwt, jwt)
      _                  -> halt send_resp(conn, 401, "No token provided")
    end
  end

  def validate_jwt(conn, _) do
    case JWT.verify(conn.assigns.jwt) do
      {:ok, payload}    -> assign_user(conn, payload)
      {:error, message} -> halt send_resp(conn, 401, message)
    end
  end

  defp assign_user(conn, %{"data" => data}) do
    assign(conn, :user, Repo.get(User, data["id"]))
  end
end
