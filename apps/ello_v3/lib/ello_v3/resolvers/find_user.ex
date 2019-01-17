defmodule Ello.V3.Resolvers.FindUser do
  import Ello.Auth

  def call(_parent, %{username: username} = args, _resolver) do
    user = Ello.Core.Network.user(Map.merge(args, %{id_or_username: "~#{username}"}))
    if can_view_user?(%{assigns: args}, user)
      {:ok, user}
    else
      {:ok, nil}
    end
  end

  def call(_parent, %{id: id} = args, _resolver) do
    user = Ello.Core.Network.user(Map.merge(args, %{id_or_username: id}))
    if can_view_user?(%{assigns: args}, user)
      {:ok, user}
    else
      {:ok, nil}
    end
  end
end
