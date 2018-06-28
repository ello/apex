defmodule Ello.V3.Resolvers.FollowingPostStream do
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.Core.Network
  import Ello.V3.Resolvers.PaginationHelpers
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_parent, %{kind: :trending} = args, _resolution) do

  end
  def call(_parent, %{kind: :recent, current_user: current_user} = args, _resolution) do
    stream = Stream.fetch(Map.merge(args, %{
      keys: ["#{current_user.id}" | Network.following_ids(current_user)],
    }))

    {:ok, %{
      posts: track(stream.posts, args, %{kind: "following", id: current_user.id}),
      next:  stream.before,
      is_last_page: is_last_page(args, stream.posts),
    }}
  end

  def new_content(_parent, %{since: since, current_user: current_user} = args, _resolution) do
    stream_opts = Map.merge(args, %{
      per_page: 1,
      keys: ["#{current_user.id}" | Network.following_ids(current_user)],
    })

    with stream <- Stream.fetch(stream_opts),
         %{posts: [%{created_at: last_modified} | _]} <- stream,
         1 <- Timex.compare(last_modified, since, :seconds) do
      {:ok, %{new_content: true}}
    else
      _ -> {:ok, %{new_content: false}}
    end
  end
end
