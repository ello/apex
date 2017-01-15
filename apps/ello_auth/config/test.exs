use Mix.Config

config :ello_auth,
  jwt_alg: :hs256,
  jwt_secret: "SECRET",
  jwt_exp_duration: 30
