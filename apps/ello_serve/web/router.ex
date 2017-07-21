defmodule Ello.Serve.Router do
  use Ello.Serve.Web, :router

  pipeline :token do
    plug :accepts, ["json"]
  end

  pipeline :webapp do
    plug Ello.Serve.DefaultToHTML
    plug :accepts, ["html"]
    plug Ello.Serve.SetApp, app: "webapp"
    plug Ello.Serve.SkipPrerender
    plug Ello.Serve.FetchVersion
  end

  scope "/api/webapp-token", Ello.Serve do
    pipe_through :token
    get "/", TokenController, :show
  end

  scope "/api/serve/v1", Ello.Serve.API do
    post "/versions", VersionController, :create
    post "/versions/activate", VersionController, :activate
    post "/slack/action", SlackController, :slack_action
    # post "/slack/command", SlackController, :callback
  end

  scope "/", Ello.Serve.Webapp do
    pipe_through :webapp

    get "/",                      EditorialController, :index
    get "/discover",              DiscoverPostController, :featured
    get "/discover/trending",     DiscoverPostController, :trending
    get "/discover/recent",       DiscoverPostController, :recent
    get "/discover/all",          CategoryController, :index
    get "/discover/:category",    DiscoverPostController, :category
    get "/search",                SearchController, :index
    get "/artist-invites",        ArtistInviteController, :index

    # Logged in only routes - no fallback content required
    get "/following",             NoContentController, :show
    get "/notifications",         NoContentController, :show
    get "/invitations",           NoContentController, :show
    get "/settings",              NoContentController, :show
    get "/onboarding",            NoContentController, :show
    get "/onboarding/*rest",      NoContentController, :show

    # Join/Auth routes - no fallback content relevant
    get "/enter",                 NoContentController, :enter
    get "/join",                  NoContentController, :join
    get "/forgot",                NoContentController, :forgot

    # User routes
    get "/:username/post/:token", PostController, :show
    get "/:username/following",   RelationshipController, :following
    get "/:username/followers",   RelationshipController, :followers
    get "/:username/loves",       LoveController, :index
    get "/:username",             UserController, :show

    # Fallback for any other route
    get "/*rest",                 NoContentController, :show
  end
end
