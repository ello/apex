defmodule Ello.V3.Resolvers.UserLoveStream do
  import Ello.V3.Resolvers.PaginationHelpers
  import Ello.V3.Resolvers.PostViewHelpers

  def call(parent, %{username: "~" <> username} = args, resolution),
    do: call(parent, %{args | username: username}, resolution)
  def call(_, %{username: username} = args, _resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        loves = Ello.Core.Content.loves(Map.merge(args, %{user: %{id: user.id}}))
        loves
        |> Enum.map(&(&1.post))
        |> track(args, kind: :love, id: user.id)

        {:ok, %{
          loves: loves,
          next: next_page(loves),
          is_last_page: is_last_page(args, loves)
        }}
    end
  end
end

