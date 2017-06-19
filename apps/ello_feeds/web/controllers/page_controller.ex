defmodule Ello.Feeds.PageController do
  use Ello.Feeds.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
