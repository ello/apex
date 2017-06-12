defmodule Ello.Serve.PageController do
  use Ello.Serve.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
