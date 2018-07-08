defmodule Ello.Notifications.StreamTest do
  use Ello.Notifications.Case
  alias Ello.Notifications.Stream
  alias Stream.Item

  test "empty results" do
    user = Factory.insert(:user)
    assert stream = %Stream{} = Stream.fetch(%{current_user: user})

    assert stream.models == []
  end

  test "with notifications" do
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
    assert [%Item{}] = stream.models
  end
end
