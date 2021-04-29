# Ello.Search

Responsible for searching in our Elasticsearch indices.

# Configuration

Ello.Search expects the following environment variables:

- `ES_URL` – URL to Elasticsearch cluster
- `ES_PREFIX` – in a lot of cases, we want to prefix our index names to
  differentiate between environments. Currently, we only add the prefix to our
  staging environments and let our production environment use a prefix-less
  index name
- `FOLLOWING_SEARCH_BOOST_LIMIT` – when doing username searches, we take into
  account people that you follow. This caps the number of followers that we
  allow in the query
- `FOLLOWING_SEARCH_BOOST` – boost factor for users that you also follow that
  get returned in searches.
- `USERNAME_MATCH_BOOST` – boost factor for exact username matches
- `TEXT_CONTENT_BOOST_FACTOR` – boost factor for text relevance in post searches
- `MENTION_BOOST_FACTOR` – boost factor for user mentions within post searches
- `LANGUAGE_BOOST_FACTOR` – boost factor for preferred client language within
  post searches
