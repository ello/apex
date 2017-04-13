use Mix.Config

config :ello_search,
  es_url:                       System.get_env("ES_URL") || "http://192.168.99.100:9200",
  es_prefix:                    System.get_env("ES_PREFIX"),
  following_search_boost_limit: String.to_integer(System.get_env("FOLLOWING_SEARCH_BOOST_LIMIT") || "1000"),
  following_search_boost:       String.to_float(System.get_env("FOLLOWING_SEARCH_BOOST") || "15.0"),
  username_match_boost:         String.to_float(System.get_env("USERNAME_MATCH_BOOST") || "5.0"),
  es_default_shards:            String.to_integer(System.get_env("ES_DEFAULT_SHARDS") || "5"),
  es_default_replicas:          String.to_integer(System.get_env("ES_DEFAULT_REPLICAS") || "1")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
