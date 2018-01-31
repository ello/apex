defmodule Ello.V3.Resolvers.UserPostStream do

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

  defp next_page([]), do: nil
  defp next_page(posts) do
    DateTime.to_iso8601(List.last(posts).created_at)
  end

  # TODO: this probably needs to be shared logic
  @filter_slop 2 # Don't 204 if one blocked post gets filtered out
  defp is_last_page(args, structs, filer_slop \\ @filter_slop)
  defp is_last_page(_, [], _), do: true
  defp is_last_page(%{per_page: requested}, structs, filter_slop) do
    if requested - filter_slop > length(structs), do: true, else: false
  end
end

