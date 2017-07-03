defmodule Ello.Serve.API.SlackController do
  use Ello.Serve.Web, :controller
  alias Ello.Serve.VersionStore

  def slack_action(conn, params) do
    with encoded     <- params["payload"],
         decoded     <- URI.decode_www_form(encoded),
         {:ok, resp} <- Poison.decode(decoded),
         true        <- valid_token(resp["token"]) do
      handle_action(conn, resp)
    else
      false -> send_resp(conn, 401, "")
      _     -> send_resp(conn, 422, "")
    end
  end

  defp handle_action(conn, %{"callback_id" => "publish:" <> app} = resp) do
    [%{"name" => env, "value" => version}] = resp["actions"]
    VersionStore.activate_version(app, version, env)
    send_resp(conn, 200, "")
  end

  defp valid_token(nil), do: false
  defp valid_token(req_token) do
    req_token == Application.get_env(:ello_serve, :slack_token)
  end
end
