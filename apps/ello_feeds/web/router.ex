defmodule Ello.Feeds.Router do
  use Ello.Feeds.Web, :router

  pipeline :public do
    plug :accepts, ["rss"]
  end

  scope "/feeds", Ello.Feeds do
    pipe_through :public # Use the default browser stack

    get "/editorials", EditorialController, :index
  end
end
