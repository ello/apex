use Mix.Config

config :ello_search,
  es_url: "http://192.168.99.100:9200",
  es_prefix: System.get_env("ES_PREFIX")
