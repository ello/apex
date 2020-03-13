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
    plug Ello.Serve.XFrameOptions, :deny
  end

  pipeline :bread do
    plug Ello.Serve.DefaultToHTML
    plug :accepts, ["html"]
    plug Ello.Serve.SetApp, app: "bread"
    plug Ello.Serve.SkipPrerender
    plug Ello.Serve.FetchVersion
    plug Ello.Serve.XFrameOptions, :deny
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

  scope "/manage", Ello.Serve.Bread do
    pipe_through :bread
    get "/*rest",                 NoContentController, :show
  end

  scope "/", Ello.Serve.Webapp do
    pipe_through :webapp

    get "/",                             EditorialController, :index
    get "/discover",                     DiscoverPostController, :featured
    get "/discover/trending",            DiscoverPostController, :trending
    get "/discover/recent",              DiscoverPostController, :recent
    get "/discover/shop",                DiscoverPostController, :shop
    get "/discover/all",                 CategoryController, :index
    get "/discover/subscribed",          NoContentController, :show # Logged in only
    get "/discover/subscribed/trending", NoContentController, :show # Logged in only
    get "/discover/subscribed/recent",   NoContentController, :show # Logged in only
    get "/discover/subscribed/shop",     NoContentController, :show # Logged in only
    get "/discover/:category",           DiscoverPostController, :category
    get "/discover/:category/trending",  DiscoverPostController, :category_trending
    get "/discover/:category/recent",    DiscoverPostController, :category_recent
    get "/discover/:category/shop",      DiscoverPostController, :category_shop
    get "/search",                       SearchController, :index
    get "/invites",                      ArtistInviteIndexController, :index
    get "/invites/:id",                  ArtistInviteShowController, :show
    get "/creative-briefs",              ArtistInviteIndexController, :index
    get "/creative-briefs/:id",          ArtistInviteShowController, :show

    # Logged in only routes - no fallback content required
    get "/following",                    NoContentController, :show
    get "/notifications",                NoContentController, :show
    get "/invitations",                  NoContentController, :show
    get "/settings",                     NoContentController, :show
    get "/onboarding",                   NoContentController, :show
    get "/onboarding/*rest",             NoContentController, :show

    # Join/Auth routes - no fallback content relevant
    get "/enter",                        NoContentController, :enter
    get "/join",                         NoContentController, :join
    get "/forgot-password",              NoContentController, :forgot

    # User routes
    get "/:username/post/:token",        PostController, :show
    get "/:username/following",          RelationshipController, :following
    get "/:username/followers",          RelationshipController, :followers
    get "/:username/loves",              LoveController, :index
    get "/:username",                    UserController, :show

    # Fallback for any other route
    get "/*rest",                        NoContentController, :show
  end
end
