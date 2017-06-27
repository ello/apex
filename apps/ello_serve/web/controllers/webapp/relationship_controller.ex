defmodule Ello.Serve.Webapp.RelationshipController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Network
  plug Ello.Serve.FindUser

  def followers(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      followers: fn -> load_followers(conn.assigns.user) end
    }
  end

  def following(conn, _) do
    render_html conn, %{
      user: conn.assigns.user,
      following: fn -> load_following(conn.assigns.user) end
    }
  end

  defp load_followers(user) do
    Network.relationships(%{
      followers:    user,
      current_user: nil,
    })
  end

  defp load_following(user) do
    Network.relationships(%{
      following:    user,
      current_user: nil,
    })
  end
end
