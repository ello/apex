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
    loves = Content.loves(standard_params(conn, %{
      user: conn.assigns.user,
    }))
    track(conn, loves, steam_kind: "loves", stream_id: conn.assigns.user.id)
    loves
  end
end
