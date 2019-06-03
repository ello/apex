# Ello.Auth

Ello.Auth provides plugs for authenticating requests and verifying JWTs.

Ello.Auth is a normal mix project with a Plug dependency. It depends on
`Ello.Core` to lookup users.

**NOTE** - While this app can generate tokens, it is not expected to do so in
production. This is a convience for testing and may be of use in the future.

## Configuration

Ello.Auth expects the following environmental variables in production (like)
environments:

* JWT_PRIVATE_KEY - Key used to sign JWT tokens.
* ACCESS_TOKEN_EXPIRATION_SECONDS - How long generated tokens are valid for (see note above).
* AUTH_HOST - defaults to WEBAPP_HOST, but could be different (on rainbow 'ello-fg-rainbow' doesn't work, has to be 'ello-pre-production')

Ello.Auth also has the following application configuration options:

* :user_lookup_mfa - The Module, function, and arity of a function that accepts an id and returns a user (or user map).

