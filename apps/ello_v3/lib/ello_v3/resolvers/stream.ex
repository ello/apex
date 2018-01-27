defmodule Ello.V3.Resolvers.Stream do
  @firehose_key "all_post_firehose"
  def firehose(_, args, _) do
    stream = Ello.Stream.fetch(%{
      current_user: nil,
      before:       args[:before],
      keys:         [@firehose_key],
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
      allow_nudity: true,
    })

    {:ok, %{next: stream.before, posts: stream.posts}}
  end

  def user(_, %{username: username} = args, resolution) do
    case Ello.Core.Network.user(%{id_or_username: "~#{username}", preload: false}) do
      nil -> {:error, "User not found"}
      user ->
        posts = Ello.Core.Content.posts(%{
          user_id:      user.id,
          current_user: nil,
          before:       args[:before],
          per_page:     10,
          allow_nsfw:   false,
          allow_nudity: true,
        })
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

