use Mix.Config

config :ello_auth,
  jwt_alg: :rs512,
  jwt_private_key: System.get_env("JWT_PRIVATE_KEY"),
  jwt_exp_duration: System.get_env("ACCESS_TOKEN_EXPIRATION_SECONDS")
