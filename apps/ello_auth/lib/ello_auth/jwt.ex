defmodule Ello.Auth.JWT do
  @moduledoc """

  """

  @doc """
  Verifies an Ello JWT is correctly signed and has appropriate data.

  Checks `exp` and `iss` claims. Does not require user info.

  Returns {:ok, payload} or {:error, reason}
  """
  @spec verify(token :: String.t) :: {:ok, payload :: Map.t} | {:error, reason: String.t}
  def verify(""), do: verify(nil)
  def verify(nil), do: {:error, "No token found"}
  def verify(jwt) do
    jwt
    |> Joken.token
    |> Joken.with_validation("exp", &(&1 > Joken.current_time))
    |> Joken.with_validation("iss", &(&1 == "Ello, PBC"))
    |> Joken.with_signer(jwt_signer())
    |> Joken.verify!
  end

  @doc """
  Generate a public JWT token (with no user info)

  See Ello.Auth.JWT.generate/1 to generate a user token.
  """
  @spec generate() :: String.t
  def generate do
    sign_token(%{
      exp: Joken.current_time + jwt_exp_duration(),
      iss: "Ello, PBC",
    })
  end

  @doc """
  Generate a user specific JWT token.

  Expects a map with id: user_id. (User struct is fine).

  See Ello.Auth.JWT.generate/0 to generate a public token.
  """
  @spec generate(user :: %{id: number}) :: String.t
  def generate(%{id: id}) do
    sign_token(%{
      exp: Joken.current_time + jwt_exp_duration(),
      iss: "Ello, PBC",
      data: %{
        id: id
      }
    })
  end

  defp sign_token(payload) do
    payload
    |> Joken.token
    |> Joken.with_signer(jwt_signer())
    |> Joken.sign
    |> Joken.get_compact
  end

  # Let the per environment config set what algorithm we are using for signing
  # JWT tokens. Defaults to dev/staging/production's RSA Private/Public keys.
  defp jwt_signer do
    case Application.get_env(:ello_auth, :jwt_alg, :rs512) do
      :rs512 -> rs512_signer()
      :hs256 -> hs256_signer()
    end
  end

  # In Dev/Production we use a RSA Private/Public Key pair to sign tokens.
  # Steps:
  # 1. Grab key from config (set in config.ex)
  # 2. Convert PEM style private key to a JWK (JSON WEB KEY)
  # 3. Convert to the proper RS512 Joken.Signer
  defp rs512_signer do
    Application.get_env(:ello_auth, :jwt_private_key)
    |> JOSE.JWK.from_pem
    |> Joken.rs512
  end

  # In test we just use a simple string to sign tokens so this service does not
  # need the private key.
  def hs256_signer do
    Application.get_env(:ello_auth, :jwt_secret)
    |> Joken.hs256
  end

  # How long should generated tokens be valid for?
  defp jwt_exp_duration do
    Application.get_env(:ello_auth, :jwt_exp_duration, 2700)
  end
end
