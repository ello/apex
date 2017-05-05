use Mix.Config

config :ello_search, ecto_repos: []

config :ello_search,
  es_url:                       System.get_env("ES_URL") || "http://localhost:9200",
  es_prefix:                    System.get_env("ES_PREFIX"),
  following_search_boost_limit: String.to_integer(System.get_env("FOLLOWING_SEARCH_BOOST_LIMIT") || "1000"),
  following_search_boost:       String.to_float(System.get_env("FOLLOWING_SEARCH_BOOST") || "15.0"),
  username_match_boost:         String.to_float(System.get_env("USERNAME_MATCH_BOOST") || "5.0"),
  text_content_boost_factor:    String.to_float(System.get_env("TEXT_CONTENT_BOOST_FACTOR") || "2.0"),
  mention_boost_factor:         String.to_float(System.get_env("MENTION_BOOST_FACTOR") || "0.5"),
  language_boost_factor:        String.to_float(System.get_env("ES_TRENDING_DETECTED_LANGUAGE_WEIGHT") || "3.0"),
  es_default_shards:            String.to_integer(System.get_env("ES_DEFAULT_SHARDS") || "5"),
  es_default_replicas:          String.to_integer(System.get_env("ES_DEFAULT_REPLICAS") || "1"),
  post_trending_recency_weight: String.to_float(System.get_env("POST_TRENDING_RECENCY_WEIGHT") || "1.0"),
  post_trending_recency_scale:  System.get_env("POST_TRENDING_RECENCY_SCALE") || "3h",
  post_trending_recency_offset: System.get_env("POST_TRENDING_RECENCY_OFFSET") || "1d"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
