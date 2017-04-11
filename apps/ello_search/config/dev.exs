use Mix.Config

config :ello_search,
  es_url: "http://192.168.99.100:9200",
  es_prefix: System.get_env("ES_PREFIX"),
  following_search_boost_limit: System.get_env("FOLLOWING_SEARCH_BOOST_LIMIT"),
  following_search_boost: System.get_env("FOLLOWING_SEARCH_BOOST"),
  username_match_boost: System.get_env("USERNAME_MATCH_BOOST")
  # ES_DEFAULT_SHARDS || 5
  # ES_DEFAULT_REPLICAS || 1
