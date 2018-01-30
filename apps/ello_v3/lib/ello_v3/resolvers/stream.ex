defmodule Ello.V3.Resolvers.Stream do
  import Ello.V3.StandardParams

  @firehose_key "all_post_firehose"
  def firehose(_, _args, resolution) do
    stream = Ello.Stream.fetch(standard_params(resolution, %{
      keys:         [@firehose_key],
    }))
    {:ok, %{next: stream.before, posts: stream.posts}}
  end

  def user_stream(_, %{username: username}, resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        posts = Ello.Core.Content.posts(standard_params(resolution, %{
          user_id:      user.id,
        }))
        {:ok, %{
          next: DateTime.to_iso8601(List.last(posts).created_at),
          posts: posts
        }}
      end
  end

  def categories(_, %{stream_type: _type}, _resolution) do
    {:ok, %{
      next: nil,
      posts: []
    }}
  end
end

