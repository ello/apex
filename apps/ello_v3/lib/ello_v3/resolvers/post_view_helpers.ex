defmodule Ello.V3.Resolvers.PostViewHelpers do
  alias Ello.Events
  alias Ello.Events.CountPostView
  alias Ello.Core.Content.{
    Post,
    Love,
  }
  alias Ello.Core.Discovery.{
    Editorial,
    CategoryPost,
  }
  alias Ello.Core.Contest.{
    ArtistInviteSubmission,
  }
  alias Ello.Notifications

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
  defp post_ids(%{} = struct), do: post_ids([struct])
  defp post_ids(models) when is_list(models) do
    models
    |> Enum.map(&post_id(&1))
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end

  defp post_id(%Post{id: id}), do: id
  defp post_id(%Editorial{post_id: post_id}) when not is_nil(post_id), do: post_id
  defp post_id(%Editorial{curated_posts: posts}) when is_list(posts), do: Enum.map(posts, &(&1.id))
  defp post_id(%Love{post_id: post_id}), do: post_id
  defp post_id(%ArtistInviteSubmission{post_id: post_id}), do: post_id
  defp post_id(%CategoryPost{post_id: post_id}), do: post_id
  defp post_id(%Notifications.Stream.Item{subject: subject}), do: post_id(subject)
  defp post_id(_), do: nil

  defp user_id(%{current_user: %{id: id}}), do: id
  defp user_id(_), do: nil

  defp stream_id(%{id: id}), do: id
  defp stream_id(_), do: nil
end
