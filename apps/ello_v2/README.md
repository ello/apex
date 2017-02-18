# Ello.V2

Read only ello.co/api/v2 compliant JSON API.

Ello.V2 is primarially concerned with HTTP Routing and JSON rendering. Data
query logic and storage is handled by Ello.Core and friends.

## Currently serving the following API endpoints:

* GET /api/v2/categories
* GET /api/v2/categories/:id
* GET /api/v2/users/:id_or_username
* GET /api/v2/posts/:id_or_token

## Data Format

The Apex Ello.V2 API aims to maintain full compatability with the Ruby Ello
Mothership API. This API therefore emits JSON reminiscint of RC1 of the
[JSON-API spec](http://jsonapi.org/), the version of JSON-API present when
V2 was initially released.

## Configuration

Ello.V2 expects the following environmental variables in production
(like) environments:

* SOCIAL_ICONS_URL - The URL used for grabbing icons used for links in a user's
  profile. Defaults to "https://social-icons.ello.co".
* ASSET_HOST - The URL used for user uploaded assets. In order to utilize domain
  sharding, there is a "%d" that gets overridden with an integer value of 0-3.
