defmodule Ello.Core.ContentTest do
  use Ello.Core.Case
  alias Ello.Core.{Content, Image}

  setup do
    cat1 = Factory.insert(:category)
    {:ok,
      category: cat1,
      post: Factory.insert(:post, category_ids: [cat1.id]),
      user: Factory.insert(:user),
      nsfw_post: Factory.insert(:post, %{ is_adult_content: true }),
      nudity_post: Factory.insert(:post, %{ has_nudity: true }),
    }
  end

  test "post/4 - id", %{post: post} do
    fetched_post = Content.post(post.id, nil, true, true)
    assert fetched_post.id == post.id
  end

  test "post/4 - token", %{post: post} do
    fetched_post = Content.post("~#{post.token}", nil, true, true)
    assert fetched_post.token == post.token
  end

  test "post/4 - id - with user", %{user: user, post: post} do
    fetched_post = Content.post(post.id, user, true, true)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user == nil
  end

  test "post/4 - includes reposted_source", %{user: user, post: post} do
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(repost.id, user, true, true)
    assert fetched_post.id == repost.id
    assert fetched_post.reposted_source.id == post.id
  end

  test "post/4 - includes assets", %{user: user, post: post} do
    asset1 = Factory.insert(:asset, %{post: post})
    asset2 = Factory.insert(:asset, %{post: post})
    fetched_post = Content.post(post.id, user, true, true)
    assert Enum.any?(fetched_post.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.assets, &(&1.id == asset2.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.assets
  end

  test "post/4 - includes assets for reposted source", %{user: user, post: post} do
    asset1 = Factory.insert(:asset, %{post: post})
    asset2 = Factory.insert(:asset, %{post: post})
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(repost.id, user, true, true)
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset2.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.reposted_source.assets
  end

  test "post/4 - includes categories", %{user: user, post: post, category: cat} do
    cat_id = cat.id
    fetched_post = Content.post(post.id, user, true, true)
    assert fetched_post.id == post.id
    assert [%{id: ^cat_id}] = fetched_post.categories
  end

  test "post/4 - with user - does allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(post.id, user, true, true)
    assert fetched_post.id == post.id
  end

  test "post/4 - with user - does not allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(post.id, user, false, false)
    refute fetched_post
  end

  test "post/4 - with user - does allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(post.id, user, true, true)
    assert fetched_post.id == post.id
  end

  test "post/4 - with user - does not allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(post.id, user, false, false)
    refute fetched_post
  end

  test "post/4 - does not return blocked author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(blocked_post.id, user, false, false)
    refute fetched_post
  end

  test "post/4 - does not return blocked repost author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    blocked_repost = Factory.insert(:post, %{reposted_source: blocked_post})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(blocked_repost.id, user, true, true)
    refute fetched_post
  end

  test "post/4 - does not return banned author" do
    banned_author = Factory.insert(:user, %{locked_at: Ecto.DateTime.utc})
    banned_post = Factory.insert(:post, %{author: banned_author})
    fetched_post = Content.post(banned_post.id, nil, true, true)
    refute fetched_post
  end

  test "post/4 - does not return banned repost author" do
    banned_author = Factory.insert(:user, %{locked_at: Ecto.DateTime.utc})
    banned_post = Factory.insert(:post, %{author: banned_author})
    banned_repost = Factory.insert(:post, %{reposted_source: banned_post})
    fetched_post = Content.post(banned_repost.id, nil, true, true)
    refute fetched_post
  end

  test "post/4 - does not return private author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    fetched_post = Content.post(private_post.id, nil, true, true)
    refute fetched_post
  end

  test "post/4 - does not return private repost author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    private_repost = Factory.insert(:post, %{reposted_source: private_post})
    fetched_post = Content.post(private_repost.id, nil, true, true)
    refute fetched_post
  end

  test "post/4 - with user - has reposted loved watching", %{user: user, post: post} do
    repost = Factory.insert(:post, %{author: user, reposted_source: post})
    love = Factory.insert(:love, %{post: post, user: user})
    watch = Factory.insert(:watch, %{post: post, user: user})
    fetched_post = Content.post(post.id, user, true, true)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user.id == repost.id
    assert fetched_post.love_from_current_user.id == love.id
    assert fetched_post.watch_from_current_user.id == watch.id
  end

end
