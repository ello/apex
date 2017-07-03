defmodule Ello.Serve.TokenController do
  use Ello.Serve.Web, :controller
  alias Ello.Auth.PublicToken

  def show(conn, _) do
    json(conn, %{"token" => public_token()})
  end

  defp public_token do
    PublicToken.fetch(
      Application.get_env(:ello_serve, :webapp_oauth_client_id),
      Application.get_env(:ello_serve, :webapp_oauth_client_secret)
    )
  end
end
