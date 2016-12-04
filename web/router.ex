defmodule Ello.Router do
  use Ello.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Ello do
    pipe_through :api
  end
end
