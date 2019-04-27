defmodule TH.Dash.Router do
  use TH.Dash.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/cidash", TH.Dash do
    pipe_through :api

    get "/ping", StatusController, :ping
    get "/secrets", SecretsController, :index
  end
end
