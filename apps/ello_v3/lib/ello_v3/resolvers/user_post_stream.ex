defmodule Ello.V3.Resolvers.UserPostStream do
  import Ello.V3.StandardParams

  def call(parent, %{username: "~" <> username}, resolution),
    do: call(parent, %{username: username}, resolution)
  def call(_, %{username: username}, resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        posts = Ello.Core.Content.posts(standard_params(resolution, %{
          user_id:      user.id,
        }))
        {:ok, %{
          next: next_page(posts),
          posts: posts
        }}
      end
  end

  defp next_page([]), do: nil
  defp next_page(posts) do
    DateTime.to_iso8601(List.last(posts).created_at)
  end
end

