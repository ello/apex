defmodule Ello.V3.Resolvers.FindUser do
  def call(_parent, %{username: username} = args, _resolver) do
    {:ok, Ello.Core.Network.user(Map.merge(args, %{id_or_username: "~#{username}"}))}
  end

  def call(_parent, %{id: id} = args, _resolver) do
    {:ok, Ello.Core.Network.user(Map.merge(args, %{id_or_username: id}))}
  end
end
