use Mix.Config

config :ello_search, ecto_repos: []

config :elastix,
  custom_headers: {Ello.Search.Client, :headers, []},
  httpoison_options: [hackney: [pool: :elastix_pool]]

config :ello_search,
  es_url:                       System.get_env("ES_URL") || "http://localhost:9200",
  aws_es_url:                   System.get_env("AWS_ES_URL"),
  es_prefix:                    System.get_env("ES_PREFIX"),
  users_active_index_name:      System.get_env("USERS_ACTIVE_INDEX_NAME") || "users",
  posts_active_index_name:      System.get_env("POSTS_ACTIVE_INDEX_NAME") || "posts",
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
  post_trending_recency_offset: System.get_env("POST_TRENDING_RECENCY_OFFSET") || "1d",
  following_trending_recency_weight: String.to_float(System.get_env("FOLLOWING_TRENDING_RECENCY_WEIGHT") || "1.0"),
  following_trending_recency_scale:  System.get_env("FOLLOWING_TRENDING_RECENCY_SCALE") || "7d",
  following_trending_recency_offset: System.get_env("FOLLOWING_TRENDING_RECENCY_OFFSET") || "1d",
  category_trending_recency_weight:  String.to_float(System.get_env("CATEGORY_TRENDING_RECENCY_WEIGHT") || "1.0"),
  category_trending_recency_scale:   System.get_env("CATEGORY_TRENDING_RECENCY_SCALE") || "7d",
  category_trending_recency_offset:  System.get_env("CATEGORY_TRENDING_RECENCY_OFFSET") || "1d",
  post_trending_comment_boost:  String.to_float(System.get_env("POST_TRENDING_COMMENT_BOOST") || "0.3"),
  post_trending_love_boost:     String.to_float(System.get_env("POST_TRENDING_LOVE_BOOST") || "0.05"),
  post_trending_view_boost:     String.to_float(System.get_env("POST_TRENDING_VIEW_BOOST") || "0.00001"),
  post_trending_repost_boost:   String.to_float(System.get_env("POST_TRENDING_REPOST_BOOST") || "0.8")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
