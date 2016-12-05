defmodule Ello.Router do
  use Ello.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  @read [:index, :show]

  scope "/v2", alias: Ello.V2, as: :v2 do
    pipe_through :api

    resources "/categories", CategoryController, only: @read
  end
end
