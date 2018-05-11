defmodule Ello.V3.Resolvers.PostViewHelpers do
  alias Ello.Events
  alias Ello.Events.CountPostView
  alias Ello.Core.Content.Post
  alias Ello.Core.Discovery.Editorial

  @doc """
  Track post views.

  Accepts models, the entire argument map, and the tracking options map. Returns models unchanged.

  Tracking options are :kind and :id
  """
  def track(models, args, opts) do
    track_post_ids(post_ids(models), args, opts)
    models
  end

  defp track_post_ids([], _args, _opts), do: []
  defp track_post_ids(ids, args, opts) do
    Events.publish(%CountPostView{
      post_ids:    ids,
      user_id:     user_id(args),
      stream_kind: opts[:kind],
      stream_id:   stream_id(opts),
    })
  end

  defp post_ids([]), do: []
  defp post_ids(nil), do: []
  defp post_ids(%Post{id: id}), do: [id]
  defp post_ids([%Post{} | _] = posts), do: Enum.map(posts, &(&1.id))
  defp post_ids([%Editorial{} | _] = editorials) do
    editorials
    |> Enum.map(&(&1.post_id))
    |> Enum.reject(&is_nil/1)
  end

  defp user_id(%{current_user: %{id: id}}), do: id
  defp user_id(_), do: nil

  defp stream_id(%{id: id}), do: id
  defp stream_id(_), do: nil
end
