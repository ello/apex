defmodule Ello.V2.Router do
  use Ello.V2.Web, :router
  use Honeybadger.Plug

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v2", Ello.V2 do
    pipe_through :api

    get "/ping", StatusController, :ping
  end
end
