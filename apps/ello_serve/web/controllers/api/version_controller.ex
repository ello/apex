defmodule Ello.Serve.API.VersionController do
  alias Ello.Serve.VersionStore
  use Ello.Serve.Web, :controller

  plug :require_auth

  def create(conn, params) do
    case VersionStore.put_version(params["app"], params["version"], params["html"]) do
      :ok -> send_resp(conn, 201, "")
      _   -> send_resp(conn, 422, "")
    end
  end

  def activate(conn, params) do
    case VersionStore.activate_version(params["app"], params["version"], params["environment"]) do
      :ok -> send_resp(conn, 200, "")
      _   -> send_resp(conn, 422, "")
    end
  end

  defp require_auth(conn, _) do
    encoded = basic_auth_header()
    case get_req_header(conn, "authorization") do
      ["Basic " <> ^encoded] -> conn
      _ ->
        conn
        |> put_resp_header("www-authenticate", ~s(Basic realm="User Visible Realm"))
        |> send_resp(401, "")
        |> halt
    end
  end

  defp basic_auth_header() do
    Base.encode64(
      Application.get_env(:ello_serve, :api_username)
      <> ":" <>
      Application.get_env(:ello_serve, :api_password)
    )
  end
end
