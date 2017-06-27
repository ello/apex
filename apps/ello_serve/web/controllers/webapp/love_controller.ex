defmodule Ello.Serve.Webapp.LoveController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  plug Ello.Serve.FindUser

  def index(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      loves: fn -> load_loves(conn.assigns.user) end
    }
  end

  defp load_loves(user) do
    Content.loves(%{
      user: user,
      current_user: nil,
    })
  end
end
