defmodule Ello.Core.ContentTest do
  use Ello.Core.Case
  alias Ello.Core.Content

  setup do
    {:ok,
      post: Factory.insert(:post),
      user: Factory.insert(:user),
    }
  end

  test "post/2 - id", %{post: post} do
    fetched_post = Content.post(post.id, nil)
    assert fetched_post.id == post.id
  end

  test "post/2 - token", %{post: post} do
    fetched_post = Content.post("~#{post.token}", nil)
    assert fetched_post.token == post.token
  end

  test "post/2 - id - with user", %{user: user, post: post} do
    fetched_post = Content.post(post.id, user)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user == nil
  end

  test "post/2 - id - with user - has reposted", %{user: user, post: post} do
    repost = Factory.insert(:post, %{author: user, reposted_source: post})
    fetched_post = Content.post(post.id, user)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user.id == repost.id
  end

end
