defmodule Ello.V3.Resolvers.Content do

  def find_post(_parent, %{username: username, token: token} = args, _resolver) do
    post = Ello.Core.Content.post(Map.merge(args, %{id_or_token: "~#{token}"}))
    case post do
      %{author: %{username: ^username}} -> {:ok, post}
      _ -> {:error, "Post not found"}

    end
  end
end

