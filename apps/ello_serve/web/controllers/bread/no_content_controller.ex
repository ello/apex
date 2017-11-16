defmodule Ello.Serve.Bread.NoContentController do
  use Ello.Serve.Web, :controller

  def show(conn, _) do
    render_html(conn)
  end
end
