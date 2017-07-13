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
    get "/editorials", EditorialController, :index
    get "/editorials/posts", EditorialPostController, :index
    get "/categories/:slug/posts/recent", CategoryPostController, :recent
    get "/categories/:slug/posts/trending", CategoryPostController, :trending
    get "/categories/posts/recent", CategoryPostController, :featured
    get "/discover/posts/recent", DiscoverPostController, :recent
    get "/discover/posts/trending", DiscoverPostController, :trending

    # Users And Posts
    get "/users/autocomplete", UserController, :autocomplete
    resources "/users", UserController, only: [:show, :index] do
      resources "/posts", UserPostController, only: [:index], name: :post
    end
    resources "/posts", PostController, only: [:show, :index] do
      resources "/related", RelatedPostController, only: [:index], name: :related
    end

    # Following
    head "/following/posts/recent", FollowingPostController, :recent_updated
    get "/following/posts/recent", FollowingPostController, :recent
    get "/following/posts/trending", FollowingPostController, :trending

    # Artist Invites
    resources "/artist_invites", ArtistInviteController, only: [:index, :show] do
      resources "/submissions", ArtistInviteSubmissionController, only: [:index]
    end
  end
end
