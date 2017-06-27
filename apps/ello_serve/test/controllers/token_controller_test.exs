defmodule Ello.Serve.TokenControllerTest do
  use Ello.Serve.ConnCase, async: false

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "GET /api/webapp-token", %{conn: conn} do
    Application.put_env(:ello_auth, :http_client, __MODULE__.ClientMock)
    resp = get(conn, "/api/webapp-token")
    Application.delete_env(:ello_auth, :http_client)

    token = json_response(resp, 200)["token"]
    assert token["access_token"]
  end

  defmodule ClientMock do
    def fetch_token("client_id", "client_secret") do
      created_at = DateTime.to_unix(DateTime.utc_now)
      token_json = %{
        "access_token" => Ello.Auth.JWT.generate(),
        "token_type"   => "bearer",
        "expires_in"   => 86400,
        "created_at"   => created_at, #seconds utc
      }
      {:ok, token_json}
    end
  end
end
