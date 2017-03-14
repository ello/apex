defmodule Ello.V2.Router do
  use Ello.V2.Web, :router

  @read [:index, :show]

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v2", Ello.V2 do
    pipe_through :api

    get "/ping", StatusController, :ping
    resources "/categories", CategoryController, only: @read
    resources "/users", UserController, only: [:show] do
      resources "/posts", UserPostController, only: [:index], name: :post
    end
    resources "/posts", PostController, only: [:show] do
      resources "/related", RelatedPostController, only: [:index], name: :related

    end
  end
end
