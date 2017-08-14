defmodule Ello.Serve.Webapp.EditorialController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Discovery

  def index(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about.",
      editorials: fn -> editorials(conn) end,
    })
  end

  defp editorials(conn) do
    editorials = Discovery.editorials(standard_params(conn, %{preview: false}))
    track(conn, editorials, stream_kind: "editorial")
    editorials
  end
end
