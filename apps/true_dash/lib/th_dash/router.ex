defmodule TH.TrueDash.Router do
  use TH.TrueDash.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/cidash", TH.TrueDash do
    pipe_through :api

    get "/ping", StatusController, :ping
    get "/secrets", SecretsController, :index
    get "/talenthouse/login", TalenthouseController, :login
    post "/talenthouse/login", TalenthouseController, :login
    get "/talenthouse/browse", TalenthouseController, :browse
    get "/talenthouse/statistics", TalenthouseController, :statistics
    delete "/talenthouse/statistics", TalenthouseController, :delete_statistics
  end
end
