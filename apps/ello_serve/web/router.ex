defmodule Ello.Serve.Router do
  use Ello.Serve.Web, :router

  pipeline :webapp do
    plug :accepts, ["html"]
    plug Ello.Serve.SetApp, app: :webapp
    plug Ello.Serve.FetchVersion
  end

  scope "/", Ello.Serve.Webapp do
    pipe_through :webapp

    # TODO: Custom noscript & meta for discovery
    # get "/",                      EditorialController, :featured
    # get "/discover",              DiscoverController, :featured
    # get "/discover/trending",     DiscoverController, :trending
    # get "/discover/recent",       DiscoverController, :recent
    # get "/discover/all",          DiscoverController, :all_categories
    # get "/discover/:category",    DiscoverController, :category

    # TODO: Custom noscript & meta for search
    # get "/search",                NoContentController, :show

    # Logged in only routes - no fallback content required
    get "/following",             NoContentController, :show
    get "/invitations",           NoContentController, :show
    get "/settings",              NoContentController, :show
    get "/onboarding",            NoContentController, :show
    get "/onboarding/*rest",      NoContentController, :show

    # Join/Auth routes - no fallback content relevant
    get "/enter",                 NoContentController, :enter
    get "/join",                  NoContentController, :join
    get "/forgot",                NoContentController, :forgot

    # User routes
    # get "/:username",             UserController, :show
    get "/:username/post/:token", PostController, :show
    # get "/:username/following",   UserController, :following
    # get "/:username/followers",   UserController, :following
    # get "/:username/loves",       UserController, :loves

    # Fallback for any other route
    get "/*rest",                 NoContentController, :show
  end
end
