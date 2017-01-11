defmodule Ello.JWT do
  @doc """
  Verifies a JWT is correctly signed and has appropriate data.
  Returns {:ok, payload} or {:error, reason}
  """
  def verify(""), do: verify(nil)
  def verify(nil), do: {:error, "No token found"}
  def verify(jwt) do
    jwt
    |> Joken.token
    |> Joken.with_validation("exp", &(&1 > Joken.current_time))
    |> Joken.with_validation("iss", &(&1 == "Ello, PBC"))
    |> Joken.with_validation("data", &is_binary(&1["username"]))
    |> Joken.with_validation("data", &is_integer(&1["id"]))
    |> Joken.with_signer(jwt_signer)
    |> Joken.verify!
  end

  # Let the per environment config set what algorithm we are using for signing
  # JWT tokens. Defaults to dev/staging/production's RSA Private/Public keys.
  defp jwt_signer do
    case Application.get_env(:ello, :jwt_alg, :rs512) do
      :rs512 -> rs512_signer
      :hs256 -> hs256_signer
    end
  end

  # In Dev/Production we use a RSA Private/Public Key pair to sign tokens.
  # Steps:
  # 1. Grab key from config (set in config.ex)
  # 2. Convert PEM style private key to a JWK (JSON WEB KEY)
  # 3. Convert to the proper RS512 Joken.Signer
  defp rs512_signer do
    Application.get_env(:ello, :jwt_private_key)
    |> JOSE.JWK.from_pem
    |> Joken.rs512
  end

  # In test we just use a simple string to sign tokens so this service does not
  # need the private key.
  def hs256_signer do
    Application.get_env(:ello, :jwt_secret)
    |> Joken.hs256
  end
end
