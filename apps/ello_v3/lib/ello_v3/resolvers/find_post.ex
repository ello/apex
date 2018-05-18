defmodule Ello.V3.Resolvers.FindPost do
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_parent, %{token: token} = args, _resolver) do
    args = Map.put(args, :preloads, Map.merge(%{author: %{}}, args.preloads))
    post = Ello.Core.Content.post(Map.merge(args, %{id_or_token: "~#{token}"}))
    check_username(post, args[:username], args)
  end

  def call(_parent, %{id: id} = args, _resolver) do
    args = Map.put(args, :preloads, Map.merge(%{author: %{}}, args.preloads))
    post = Ello.Core.Content.post(Map.merge(args, %{id_or_token: id}))
    check_username(post, args[:username], args)
  end

  def call(_parent, %{token: token} = args, _resolver) do
    args = Map.put(args, :preloads, Map.merge(%{author: %{}}, args.preloads))
    post = Ello.Core.Content.post(Map.merge(args, %{id_or_token: "~#{token}"}))
    check_username(post, args[:username], args)
  end

  defp check_username(post, nil, args), do: {:ok, do_track(post, args)}
  defp check_username(%{author: %{username: u}} = post, u, args), do: {:ok, do_track(post, args)}
  defp check_username(_, _, _), do: {:error, "Post not found"}

  defp do_track(post, args), do: track(post, args, kind: :user, id: post.author_id)
end

