defmodule Ello.Notifications.Stream.Loader do
  alias Ello.Notifications.Stream
  alias Stream.Item
  alias Ello.Core.{
    Content,
    Network,
    Contest,
    Discovery,
  }

  def load(stream) do
    stream
    |> build_items
    |> load_related
  end

  defp build_items(%{__response: json} = stream) do
    items = Enum.map json, fn (j) ->
      IO.inspect(j["kind"])
      %Item{
        user_id: j["user_id"],
        kind: j["kind"],
        subject_id: j["subject_id"],
        subject_type: j["subject_type"],
        created_at: j["created_at"],
        originating_user_id: j["originating_user_id"],
      }
    end

    Map.put(stream, :models, items)
  end

  defp load_related(%{preload: false} = stream), do: stream
  defp load_related(%{models: items, preload: true} = stream) do
    subjects = preload_subjects(stream)
    users = preload_orignating_users(stream)

    loaded = Enum.map(items, &Map.merge(&1, %{
      subject: subjects[subject_type(&1)][&1.subject_id],
      originating_user: users[&1.originating_user_id],
    }))

    %{stream | models: loaded}
  end

  @user_preloads %{current_user_state: %{}}
  @post_preloads %{
    assets: %{},
    author: @user_preloads,
    current_user_state: %{},
    post_stats: %{},
    reposted_source: %{
      assets: %{},
      current_user_state: %{},
      post_stats: %{},
      author: @user_preloads,
    }
  }
  @comment_preloads %{parent_post: @post_preloads, author: @user_preloads, assets: %{}}
  @love_preloads %{post: @post_preloads, user: @user_preloads}
  @category_user_preloads %{user: @user_preloads, category: %{}}
  @category_post_preloads %{post: @post_preloads, category: %{}, featured_by: @user_preloads}
  @artist_invite_submission_preloads %{post: @post_preloads, artist_invite: %{}}
  @watch_preloads %{post: @post_preloads}

  defp preload_orignating_users(stream) do
    Enum.reduce(Network.users(%{
      ids: Enum.map(stream.models, &(&1.originating_user_id)),
      current_user: stream.current_user,
      preloads: @user_preloads,
    }), %{}, &Map.put(&2, &1.id, &1))
  end

  defp preload_subjects(stream) do
    stream.models
    |> Enum.group_by(&subject_type/1)
    |> Enum.map(&async_fetch_subjects(&1, stream))
    |> Enum.map(&Task.await(&1, 10_000))
    |> Enum.reduce(%{}, fn ({type, models}, loaded) ->
      Map.put(loaded, type, Enum.reduce(models, %{}, &Map.put(&2, &1.id, &1)))
    end)
  end


  # Comments have subject_type Post, but should be loaded as comments with the parent post.
  @comment_kinds ~w(
    comment_mention_notification
    comment_notification
    comment_on_repost_notification
    comment_on_original_post_notification
    watch_comment_notification
  )
  defp subject_type(%{subject_type: "Post", kind: kind}) when kind in @comment_kinds, do: "Comment"
  defp subject_type(%{subject_type: type}), do: type


  defp async_fetch_subjects({type, items}, %{current_user: current_user}) do
    ids = items
          |> Enum.map(&(&1.subject_id))
          |> Enum.dedup
    Task.async(__MODULE__, :fetch_subjects, [type, ids, current_user])
  end

  def fetch_subjects("Post", ids, user) do
    {"Post", Content.posts(%{
      ids: ids,
      current_user: user,
      preloads: @post_preloads,
    })}
  end
  def fetch_subjects("Comment", ids, user) do
    {"Comment", Content.comments(%{
      ids: ids,
      current_user: user,
      preloads: @comment_preloads,
    })}
  end
  def fetch_subjects("User", ids, user) do
    {"User", Network.users(%{
      ids: ids,
      current_user: user,
      preloads: @user_preloads,
    })}
  end
  def fetch_subjects("CategoryUser", ids, user) do
    {"CategoryUser", Discovery.category_users(%{
      ids: ids,
      current_user: user,
      preloads: @category_user_preloads,
    })}
  end
  def fetch_subjects("CategoryPost", ids, user) do
    {"CategoryPost", Discovery.category_posts(%{
      ids: ids,
      current_user: user,
      preloads: @category_post_preloads,
    })}
  end
  def fetch_subjects("ArtistInviteSubmission", ids, user) do
    {"ArtistInviteSubmission", Contest.artist_invite_submissions(%{
      ids: ids,
      current_user: user,
      preloads: @artist_invite_submission_preloads,
    })}
  end
  def fetch_subjects("Love", ids, user) do
    {"Love", Content.loves(%{
      ids: ids,
      current_user: user,
      preloads: @love_preloads,
    })}
  end
  def fetch_subjects("Watch", ids, user) do
    {"Watch", Content.watches(%{
      ids: ids,
      current_user: user,
      preloads: @watch_preloads,
    })}
  end
end
