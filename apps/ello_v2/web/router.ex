defmodule Ello.V2.Router do
  use Ello.V2.Web, :router

  @read [:index, :show]

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v2", Ello.V2 do
    pipe_through :api

    get "/ping", StatusController, :ping

    # Promotionals
    resources "/categories", CategoryController, only: @read

    # Discovery
    get "/categories/:slug/posts/recent", CategoryPostController, :recent
    get "/categories/posts/recent", CategoryPostController, :featured
    get "/discover/posts/recent", DiscoverPostController, :recent

    # Users And Posts
    get "/users/autocomplete", UserController, :autocomplete
    resources "/users", UserController, only: [:show, :index] do
      resources "/posts", UserPostController, only: [:index], name: :post
    end
    resources "/posts", PostController, only: [:show, :index] do
      resources "/related", RelatedPostController, only: [:index], name: :related
    end

    # Following
    resources "/following/posts/recent", FollowingPostController, only: [:index]
  end
end
