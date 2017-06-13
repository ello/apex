defmodule Ello.Serve.Webapp.NoContentController do
  use Ello.Serve.Web, :controller

  def show(conn, _) do
    render_html(conn)
  end

  def settings(conn, _) do
    render_html(conn, %{
      title: "Tweak yo shit"
    })
  end
end
