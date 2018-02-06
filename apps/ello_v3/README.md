# Ello.V3

Read only ello.co/api/v3/graphql GraphQL API.

Ello.V3 is just a graphql layer on top of Ello.Core, Ello.Auth, Ello.Stream, Ello.Search, etc.

## Configuration

Ello.V3 expects the following environmental variables in production
(like) environments:

* ASSET_HOST - The URL used for user uploaded assets. In order to utilize domain
  sharding, there is a "%d" that gets overridden with an integer value of 0-3.
