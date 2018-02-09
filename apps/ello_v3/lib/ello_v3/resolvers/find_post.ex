defmodule Ello.V3.Resolvers.FindPost do
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_parent, %{username: username, token: token} = args, _resolver) do
    # we require author here for username verification
    args = Map.put(args, :preloads, Map.merge(%{author: %{}}, args.preloads))
    post = Ello.Core.Content.post(Map.merge(args, %{id_or_token: "~#{token}"}))
    case post do
      %{author: %{username: ^username}} = user ->
        {:ok, track(post, args, kind: :user, id: user.id)}
      _ -> {:error, "Post not found"}
    end
  end
end

