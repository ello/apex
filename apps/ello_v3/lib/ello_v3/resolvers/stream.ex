defmodule Ello.V3.Resolvers.Stream do

  @firehose_key "all_post_firehose"
  @block_slog 2
  def firehose(_, args, _resolution) do
    stream = Ello.Stream.fetch(Map.merge(args, %{keys: [@firehose_key]}))
    {:ok, %{
      next: stream.before,
      posts: stream.posts,
      is_last_page: stream.per_page - @block_slop < length(stream.posts),
    }}
  end

  def categories(_, %{stream_type: _type}, _resolution) do
    {:ok, %{
      next: nil,
      posts: []
    }}
  end
end

