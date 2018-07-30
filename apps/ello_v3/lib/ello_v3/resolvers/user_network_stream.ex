defmodule Ello.V3.Resolvers.UserNetworkStream do
  alias Ello.Core.Network
  import Ello.V3.Resolvers.PaginationHelpers

  def call(_parent, args, _resolver) do
    case find_user(args) do
      nil -> {:error, "User not found"}
      user ->
        relationships = find_relationships(args, user)
        {:ok, %{
          users: Enum.map(relationships, &get_relationship_user(&1, args[:kind])),
          is_last_page: is_last_page(args, relationships),
          next: next_page(relationships),
        }}
    end
  end

  defp find_relationships(%{kind: kind} = args, user) do
    Network.relationships(Map.put(args, kind, user))
  end

  defp find_user(%{id: id} = args) do
    Ello.Core.Network.user(Map.merge(args, %{id_or_username: id, preload: false}))
  end
  defp find_user(%{username: username} = args) do
    Ello.Core.Network.user(Map.merge(args, %{id_or_username: "~#{username}", preload: false}))
  end

  defp get_relationship_user(%{subject: user}, :following), do: user
  defp get_relationship_user(%{owner: user}, :followers), do: user
end
