defmodule Ello.V3.Resolvers.Content do
  def find_post(_parent, %{username: username, token: token}, _resolver) do
    post = Ello.Core.Content.post(%{
      current_user: nil,
      id_or_token:  "~#{token}",
      allow_nsfw:   false,
      allow_nudity: true,
      preloads: [:assets, :author, :artist_invite_submission]
    })
    case post do
      %{author: %{username: ^username}} -> {:ok, post}
      _ -> {:error, "Post not found"}

    end
  end
end

