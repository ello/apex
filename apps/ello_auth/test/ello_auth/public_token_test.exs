defmodule Ello.Auth.PublicTokenTest do
  use ExUnit.Case, async: false
  alias Ello.Auth.PublicToken

  test "getting a token" do
    Application.put_env(:ello_auth, :http_client, __MODULE__.ClientMock)
    token = PublicToken.fetch("unexpired", "secret")
    Application.delete_env(:ello_auth, :http_client)

    assert token["access_token"]
    assert token["expires_in"]

    # Second request is from memory/ets - token is exact same
    assert token == PublicToken.fetch("unexpired", "secret")
  end

  test "getting a token - that has expired" do
    Application.put_env(:ello_auth, :http_client, __MODULE__.ClientMock)
    token = PublicToken.fetch("expires-in-one", "secret")
    token2 = PublicToken.fetch("expires-in-one", "secret")

    # First request gets token from client
    assert token["access_token"]
    assert token["expires_in"] == 1

    # Second request gets token from ets (not expired yet)
    assert token == token2

    # Sleep a second
    :timer.sleep(1100)

    # Third request gets new token
    token3 = PublicToken.fetch("expires-in-one", "secret")

    # Second request is from memory/ets - token is exact same
    refute token3 == token
    Application.delete_env(:ello_auth, :http_client)
  end

  defmodule ClientMock do
    def fetch_token("unexpired", "secret") do
      created_at = DateTime.to_unix(DateTime.utc_now)
      token_json = %{
        "access_token" => Ello.Auth.JWT.generate(),
        "token_type"   => "bearer",
        "expires_in"   => 86_400,
        "scope"        => "public scoped_refresh_token",
        "created_at"   => created_at, #seconds utc
      }
      {:ok, token_json}
    end

    def fetch_token("expires-in-one", "secret") do
      created_at = DateTime.to_unix(DateTime.utc_now)
      token_json = %{
        "access_token" => Ello.Auth.JWT.generate(),
        "token_type"   => "bearer",
        "expires_in"   => 1,
        "scope"        => "public scoped_refresh_token",
        "created_at"   => created_at, #seconds utc
      }
      {:ok, token_json}
    end
  end
end
