defmodule Ello.V3.Resolvers.FindUser do
  import Ello.Auth

  def call(_parent, %{username: username} = args, _resolver) do
    view_user(args, Ello.Core.Network.user(Map.merge(args, %{id_or_username: "~#{username}"})))
  end

  def call(_parent, %{id: id} = args, _resolver) do
    view_user(args, Ello.Core.Network.user(Map.merge(args, %{id_or_username: id})))
  end

  defp view_user(_, nil), do: {:ok, nil}
  defp view_user(args, user) do
    if can_view_user?(%{assigns: args}, user) do
      {:ok, user}
    else
      {:ok, nil}
    end
  end
end
