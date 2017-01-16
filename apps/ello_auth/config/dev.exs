use Mix.Config

config :ello_auth,
  jwt_alg: :rs512,
  jwt_secret: System.get_env("JWT_PRIVATE_KEY")
