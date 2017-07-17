defmodule Ello.Serve.Webapp.RelationshipController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Network
  plug Ello.Serve.FindUser

  def followers(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      type: :followers,
      relationships: fn -> load_followers(conn) end
    }
  end

  def following(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      type: :following,
      relationships: fn -> load_following(conn) end
    }
  end

  defp load_followers(conn) do
    Network.relationships(standard_params(conn, %{
      followers: conn.assigns.user,
    }))
  end

  defp load_following(conn) do
    Network.relationships(standard_params(conn, %{
      following: conn.assigns.user,
    }))
  end
end
