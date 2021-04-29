# Ello.V2

Read only ello.co/api/v2 compliant JSON API.

Ello.V2 is primarially concerned with HTTP Routing and JSON rendering. Data
query logic and storage is handled by Ello.Core and friends.

## Currently serving the following API endpoints:

- GET /api/v2/categories
- GET /api/v2/categories/:id
- GET /api/v2/editorials
- GET /api/v2/editorial_posts
- GET /api/v2/users/:id_or_username
- GET /api/v2/posts/:id_or_token
- GET /api/v2/posts (search)
- GET /api/v2/users (search)
- GET /api/v2/following/posts/recent
- GET /api/v2/categories/posts/recent
- GET /api/v2/categories/:slug/posts/recent
- GET /api/v2/discover/posts/recent
- GET /api/v2/discover/posts/trending

## Data Format

The Apex Ello.V2 API aims to maintain full compatability with the Ruby Ello
Mothership API. This API therefore emits JSON reminiscint of RC1 of the
[JSON-API spec](http://jsonapi.org/), the version of JSON-API present when
V2 was initially released.

## Configuration

Ello.V2 expects the following environmental variables in production
(like) environments:

- `SOCIAL_ICONS_HOST` – the URL used for grabbing icons used for links in a
  user’s profile. Defaults to `https://social-icons.ello.co`
- `ASSET_HOST` – the URL used for user uploaded assets. In order to utilize
  domain sharding, there is a `%d` that gets overridden with an integer value of
  0-3
- `WEBAPP_HOST` – the public domain name, e.g. `https://ello.co` or
  `https://ello-fg-rainbow.herokuapp.com`
