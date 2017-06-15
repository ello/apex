defmodule Ello.Serve.Webapp.CategoryPostController do
  use Ello.Serve.Web, :controller

  def recent(conn, _) do
    render_html(conn)
  end
end
