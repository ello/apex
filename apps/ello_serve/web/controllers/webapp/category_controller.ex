defmodule Ello.Serve.Webapp.CategoryController do
  use Ello.Serve.Web, :controller

  def index(conn, _) do
    render_html(conn)
  end
end
