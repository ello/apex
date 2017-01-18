# Ello.V2

Read only ello.co/api/v2 compliant JSON API.

Ello.V2 is primarially concerned with HTTP Routing and JSON rendering. Data
query logic and storage is handled by Ello.Core and friends.

## Configuration

Ello.V2 expects the following environmental variables in production
(like) environments:

* SOCIAL_ICONS_URL - The URL used for grabbing icons used for links in a user's
  profile. Defaults to "https://social-icons.ello.co".
