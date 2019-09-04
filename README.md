<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Ello Apex

[![Build Status](https://travis-ci.org/ello/apex.svg?branch=master)](https://travis-ci.org/ello/apex)

A collection of endpoint serving some of the API for [ello.co](http://ello.co).

The primary Ello API (referred to as the Ello Mothership) is a Ruby on Rails
application. Apex is an effort to increase rendering performance on heavily
used read API endpoints. It is expected that the responsibility of Apex may
grow to take over write responsibility in the future.

While the Ruby Ello Mothership is not (yet) open source, the
[Swift based iOS app](https://github.com/ello/webapp) and
[React based webapp](https://github.com/ello/webapp) API consumers are OSS.
You can check out all of Ello's OSS on [Ello's github profile](https://github.com/ello)
and our philosophy on OSS is written up in @jayzes's
[blog post](https://ello.co/jayzes/post/tqll-z8u8gfbdysrk6wbkg).

## Weird redis connection issue

If the app is crashing for no good reason, check the `REDIS_URL` constants, and
make sure they _don't_ have the username.  Some nit wit who manages redix
decided that it was a good idea to _not allow_ the username as part of the
connection URL.

## Docker

The docker file to run all the services for Apex is in Mothership.  The docker
file in Apex just runs Apex.

## Organization

Apex, (module name `Ello`) is an Elixir Umbrella application wrapping several
Elixir/OTP apps. Each app is intended to manage a particular domain concern.

### `Ello.Core`

This OTP app is the core service for working with Postgres and Redis data
historically managed by the Rails Mothership. [README](/apps/ello_core/)

### `Ello.Dispatch`

Dispatch is a simple Phoenix app with no controllers of it's own. The only job
of dispatch is to delegate HTTP and Websocket requests to the proper app.
[README](/apps/ello_dispatch/)

### `Ello.V2`

V2 is a Phoenix app serving the Ello V2 JSON API. It queries `Core` and `Auth`
as needed. [README](/apps/ello_v2/)

### `Ello.Auth`

Auth provides plugs for authenticating requests and verifying JWTs. It depends
on `Core` to lookup users. [README](/apps/ello_auth/)

### `Ello.Events`

This app is responsible for processing background events, either by sending the
event to a worker queue (e.g. the `CountPostView` event) or by processing the
event in the background (or any other asynchronous processing).
[README](/apps/ello_events/)

### `Ello.Stream`

Ello Stream provides and real and test APIs for fetching our temporal post
streams.  [README](/apps/ello_stream/)

To learn more
about how we handle and serve time ordered streams check out or Go and Roshi
based

### `Ello.Search`

Ello Search provides a wrapper around our ElasticSearch cluster. Ello.Search
powers our trending algorithm in addition to the search page. [README](/apps/ello_search/).

### `Ello.Serve`

Ello Serve is resonsible for serving the HTML that powers our webapp. The webapp
builds html and pushes it to Ello.Serve. We can then activate specific versions
of the app in a given environment. Ello.Serve is also responsible for serving up
basic html for clients not supporting Javascript. [README](/apps/ello_serve/).

### `TH.TrueDash`

TrueDash is a tiny helper app to accompany Talenthouse's marketing dashboard.
It provides app tokens (so they don't have to be stored in-app) and some
"helper" endpoints for things that can't be accomplished in javascript via ajax.


## Getting Started

### Requirements

* Elixir 1.4.5 - Installation via asdf or exenv recommended.
* Postgres - Posgres.app suggested running on localhost.
* Redis - Redis.app suggested running on localhost.
* Docker & docker-compose - docker-compose up boots:
  * Ello Streams API (golang) - What Ello.Stream elixir app uses.
  * Roshi - powers Ello Streams API
  * Redis - powers Roshi.
  * ElasticSearch 5.1 - Powers Ello.Searc

### Configuration

All apps should run by default without config changes. Each app details it's
own config options in it's README.

### Commands

* To start the web server run `mix phx.server`.
* To start a console run `iex -S mix`
* To start a console and webserver run `iex -S mix phx.server`
* To run tests `mix test`
* To rebuild the database `mix do ecto.drop, ecto.create, ecto.migrate`

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all
human beings is to be kind, considerate, helpful, intelligent, responsible,
and respectful of others. To that end, we will be enforcing
[the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open
source projects. If you don’t follow the rules, you risk being ignored, banned,
or reported for abuse.

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ello/apex.

## License
Ello Apex is released under the [MIT License](/LICENSE.txt)
