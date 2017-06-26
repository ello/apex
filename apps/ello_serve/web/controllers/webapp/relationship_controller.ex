defmodule Ello.Serve.Webapp.RelationshipController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Network

  plug :find_user

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

  def find_user(%{params: %{"username" => username}} = conn, _) do
    case Network.user(%{id_or_username: "~" <> username, current_user: nil}) do
      nil ->  halt send_resp(conn, 404, "")
      user -> assign(conn, :user, user)
    end
  end
end
