defmodule Ello.V3.Resolvers.Content do
  import Ello.V3.StandardParams

  def find_post(_parent, %{username: username, token: token}, resolver) do
    post = Ello.Core.Content.post(standard_params(resolver, %{
      id_or_token:  "~#{token}",
    }))
    case post do
      %{author: %{username: ^username}} -> {:ok, post}
      _ -> {:error, "Post not found"}

    end
  end
end

