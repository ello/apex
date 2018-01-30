defmodule Ello.V3.Resolvers.Stream do
  import Ello.V3.StandardParams

  @firehose_key "all_post_firehose"
  def firehose(_, _args, resolution) do
    stream = Ello.Stream.fetch(standard_params(resolution, %{
      keys:         [@firehose_key],
    }))
    {:ok, %{next: stream.before, posts: stream.posts}}
  end

  def categories(_, %{stream_type: _type}, _resolution) do
    {:ok, %{
      next: nil,
      posts: []
    }}
  end
end

