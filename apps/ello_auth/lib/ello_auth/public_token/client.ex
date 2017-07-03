defmodule Ello.Auth.PublicToken.Client do

  def fetch_token(client_id, client_secret) do
    case make_request(client_id, client_secret) do
      {:ok, %{status_code: 200, body: body}} -> Poison.decode(body)
    end
  end

  defp make_request(id, secret) do
    body = %{
      client_id:     id,
      client_secret: secret,
      grant_type:    "client_credentials"
    }
    HTTPoison.post(
      token_url(),
      Poison.encode!(body),
      [{"Content-Type", "application/json"}]
    )
  end

  defp token_url() do
    host = Application.get_env(:ello_auth, :auth_host)
    "https://" <> host <> "/api/oauth/token"
  end
end
