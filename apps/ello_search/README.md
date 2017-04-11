# Ello.Search

Responsible for searching in our Elasticsearch indices.

# Configuration

Ello.Search expects the following environment variables:

* `ES_URL` - URL to Elasticsearch cluster
* `ES_PREFIX` - In a lot of cases, we want to prefix our index names to
  differentiate between environments. Currently, we only add the prefix to our
  staging environments and let our production environment use a prefix-less
  index name. 
* `FOLLOWING_SEARCH_BOOST_LIMIT` - When doing username searches, we take into
  account people that you follow. This caps the number of followers that we
  allow in the query.
* `FOLLOWING_SEARCH_BOOST` - Boost factor for users that you also follow that get
  returned in searches.
* `USERNAME_MATCH_BOOST` - Boost factor for exact username matches.
