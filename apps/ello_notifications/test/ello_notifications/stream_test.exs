defmodule Ello.Notifications.StreamTest do
  use Ello.Notifications.Case
  alias Ello.Notifications.Stream
  alias Stream.Item

  test "empty results - http client" do
    user = Factory.insert(:user)
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})

    assert stream.models == []
  end

  test "create, fetch, delete - http client" do
    user = Factory.insert(:user)
    author = Factory.insert(:user)
    post = Factory.insert(:post, author: author)
    assert :ok = Stream.create(%{
      user_id: user.id,
      subject_id: post.id,
      subject_type: "Post",
      kind: "post_mention_notification",
      created_at: DateTime.utc_now(),
      originating_user_id: author.id,
    })
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})
    assert [%Item{} = item] = stream.models
    assert item.user_id == user.id
    assert item.subject_id == post.id
    assert item.subject_type == "Post"
  end
end
