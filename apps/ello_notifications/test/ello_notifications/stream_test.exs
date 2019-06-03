defmodule Ello.Notifications.StreamTest do
  use Ello.Notifications.Case, async: false
  alias Ello.Notifications.Stream
  alias Ello.Core.Content.Post
  alias Stream.Item

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    Stream.Client.Test.start()
    Stream.Client.Test.reset()

    :ok
  end

  @tag :skip_on_travis
  test "empty results - http client" do
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.HTTP)
    user = Factory.insert(:user)
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})

    assert stream.models == []
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.Test)
  end

  @tag :skip_on_travis
  test "create, fetch, delete - http client" do
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.HTTP)
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, author: author)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: post.id,
      subject_type: "Post",
      kind: "post_mention_notification",
      created_at: FactoryTime.now,
      originating_user_id: author.id,
    })
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})
    assert [%Item{} = item] = stream.models
    assert item.user_id == user.id
    assert item.subject_id == post.id
    assert item.subject_type == "Post"

    assert :ok = Stream.delete_many(%{user_id: user.id})

    assert %Stream{models: []} = Stream.fetch(%{current_user: user})
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.Test)
  end

  @tag :skip_on_travis
  test "create, fetch by category, delete - http client" do
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.HTTP)
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, author: author)
    repost = Factory.insert(:post, author: author)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: post.id,
      subject_type: "Post",
      kind: "post_mention_notification",
      created_at: FactoryTime.now,
      originating_user_id: author.id,
    })
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: repost.id,
      subject_type: "Post",
      kind: "repost_notification",
      created_at: FactoryTime.now,
      originating_user_id: repost.author_id,
    })
    assert stream = %Stream{} = Stream.fetch(%{current_user: user, category: :reposts})
    assert [%Item{} = item] = stream.models
    assert item.user_id == user.id
    assert item.subject_id == repost.id
    assert item.subject_type == "Post"
    assert item.kind == "repost_notification"

    assert :ok = Stream.delete_many(%{user_id: user.id})

    assert %Stream{models: []} = Stream.fetch(%{current_user: user})
    Application.put_env(:ello_notifications, :stream_client, Stream.Client.Test)
  end

  test "empty results - test client" do
    user = Factory.insert(:user)
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})

    assert stream.models == []
  end

  test "create, fetch, delete - test client" do
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, author: author)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: post.id,
      subject_type: "Post",
      kind: "post_mention_notification",
      created_at: FactoryTime.now,
      originating_user_id: author.id,
    })
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})
    assert [%Item{} = item] = stream.models
    assert item.user_id == user.id
    assert item.subject_id == post.id
    assert item.subject_type == "Post"
    assert %Post{} = item.subject

    assert :ok = Stream.delete_many(%{user_id: user.id})

    assert %Stream{models: []} = Stream.fetch(%{current_user: user})
  end
end
