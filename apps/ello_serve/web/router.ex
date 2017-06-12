defmodule Ello.Serve.Router do
  use Ello.Serve.Web, :router

  pipeline :webapp do
    plug :accepts, ["html"]
    plug Ello.Serve.FetchVersion,   app: :webapp
    plug Ello.Serve.InjectMeta,     app: :webapp
    plug Ello.Serve.InjectNoScript, app: :webapp
  end

  scope "/", Ello.Serve.Webapp do
    pipe_through :webapp
    # Every route that isn't a user must be matched, otherwise user catches it

    get "/",                      NoContentController, :show
    get "/discover",              NoContentController, :show
    get "/discover/*",            NoContentController, :show

    # TODO: Custom noscript & meta for discovery
    # get "/",                      EditorialController, :featured
    # get "/discover",              DiscoverController, :featured
    # get "/discover/trending",     DiscoverController, :trending
    # get "/discover/recent",       DiscoverController, :recent
    # get "/discover/all",          DiscoverController, :all_categories
    # get "/discover/:category",    DiscoverController, :category

    get "/following",             NoContentController, :show
    get "/invitations",           NoContentController, :show
    get "/settings",              NoContentController, :show
    get "/search",                NoContentController, :show
    get "/enter",                 NoContentController, :show
    get "/join",                  NoContentController, :show
    get "/onboarding",            NoContentController, :show

    # User routes
    get "/:username",             UserController, :show
    get "/:username/post/:token", PostController, :show
    get "/:username/*",           NoContentController, :show

    # TODO: Custom content and headers for user resources
    # get "/:username/following",   UserController, :following
    # get "/:username/followers",   UserController, :following
    # get "/:username/loves",       UserController, :loves
  end
end
