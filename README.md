# Ello

An Elixir implementation of the Ello Mothership API.

## Organization

The Elixir Mothership, hereafter referred to as `Ello` is an Elixir Umbrella
application wrapping several Elixir/OTP apps. Each app is fundamentally
independent and could be broken into external repositories if desired.

### `Ello.Core`

This OTP app is the core service for working with Postgres and Redis data
historically managed by the Rails Mothership. [README]()

### `Ello.Dispatch`

Dispatch is a simple Phoenix app with no controllers of it's own. The only job
of dispatch is to delegate HTTP and Websocket requests to the proper app.
[README]()

### `Ello.V2`

V2 is a Phoenix app serving the Ello V2 JSON API. It queries `Core` and `Auth`
as needed. [README]()

## Getting Started

### Requirements

* Elixir 1.4 - Installation via asdf or exenv recommended.
* Postgres - Posgres.app suggested running on localhost.
* Redis - Redis.app suggested running on localhost.

### Configuration

All apps should run by default without config changes. Each app details it's
own config options in it's README.

### Commands

* To start the web server run `mix phoenix.server`.
* To start a console run `iex -S mix`
* To start a console and webserver run `iex -S mix phoenix.server`
* To run tests `mix test`
