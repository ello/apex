defmodule Ello.V3.Resolvers.CommentStream do
  import Ello.V3.Resolvers.PaginationHelpers

  alias Ello.Core.Content

  def call(_parent, %{id: id} = args, _resolution), do: resolve_comments(id, args)
  def call(_parent, %{token: token} = args, _resolution), do: resolve_comments(token, args)

  defp resolve_comments(id_or_token, args) do
    case find_post(id_or_token, args) do
      nil -> {:error, "Post not found"}
      post -> comments = Content.comments(Map.merge(args, %{post: post}))
        {:ok, %{
          comments: comments,
          next:  next_page(comments),
          is_last_page: is_last_page(args, comments),
        }}
    end
  end

  defp find_post(id_or_token, args) do
    Content.post(%{
      id_or_token: id_or_token,
      current_user: args.current_user,
      allow_nsfw: true,
      allow_nudity: true,
      preloads: %{reposted_source: %{}},
    })
  end
end
