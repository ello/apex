defmodule Ello.Router do
  use Ello.Web, :router

  pipeline :v2 do
    plug :accepts, ["json"]
    plug Ello.V2.Authenticate
  end

  @read [:index, :show]

  scope "/v2", alias: Ello.V2, as: :v2 do
    pipe_through :v2

    resources "/categories", CategoryController, only: @read
  end
end
