defmodule Ello.Serve.Webapp.LoveController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  plug Ello.Serve.FindUser

  def index(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      loves: fn -> load_loves(conn) end
    }
  end

  defp load_loves(conn) do
    Content.loves(standard_params(conn, %{
      user: conn.assigns.user,
    }))# |> Enum.map(&(&1.post))
  end
end
