defmodule Ello.V3.Resolvers.UserPostStream do
  import Ello.V3.Resolvers.PaginationHelpers

  def call(parent, %{username: "~" <> username} = args, resolution),
    do: call(parent, %{args | username: username}, resolution)
  def call(_, %{username: username} = args, _resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        posts = Ello.Core.Content.posts(Map.merge(args, %{user_id: user.id}))
        {:ok, %{
          next: next_page(posts),
          is_last_page: is_last_page(args, posts),
          posts: posts
        }}
      end
  end
end

