defmodule Ello.Serve.Webapp.CategoryController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Discovery

  def index(conn, _) do
    render_html(conn, %{
      categories: fn -> categories(conn) end,
    })
  end

  defp categories(conn) do
    Discovery.categories(standard_params(conn, %{
      meta:         false,
      promotionals: false,
      inactive:     false,
    }))
  end
end
