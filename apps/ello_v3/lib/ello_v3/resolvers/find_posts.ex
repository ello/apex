defmodule Ello.V3.Resolvers.FindPosts do
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_parent, %{tokens: tokens} = args, _resolver) do
    posts = Ello.Core.Content.posts(Map.merge(args, %{tokens: tokens}))
    {:ok, track(posts, args, kind: :editorial_curated_posts)}
  end
end

