defmodule Ello.Serve.Router do
  use Ello.Serve.Web, :router

  pipeline :webapp do
    plug :accepts, ["html"]
    plug Ello.Serve.SetApp, app: :webapp
    plug Ello.Serve.FetchVersion
  end

  # FEATURED_PAGE_DESCRIPTION: 'Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about.',
  # RECENT_PAGE_DESCRIPTION: 'Discover recent work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, Writing, Music, Textile, Skate and Cycling.',
  # SEARCH_PAGE_DESCRIPTION: 'Find work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling.',
  # SEARCH_TITLE: 'Search | Ello',
  # TITLE: 'Ello | The Creators Network.',
  # TRENDING_PAGE_DESCRIPTION: 'Explore trending work on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling.',

  scope "/", Ello.Serve.Webapp do
    pipe_through :webapp

    get "/",                      EditorialController, :index
    get "/discover",              DiscoverPostController, :featured
    get "/discover/trending",     DiscoverPostController, :trending
    get "/discover/recent",       DiscoverPostController, :recent
    get "/discover/all",          CategoryController, :index
    get "/discover/:category",    CategoryPostController, :index

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
