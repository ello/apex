defmodule Ello.Core.ContentTest do
  use Ello.Core.Case
  alias Ello.Core.{Content, Image, Repo}
  alias Ello.Core.Content.{PostsPage}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    cat1 = Factory.insert(:category)
    {:ok,
      category: cat1,
      post: Factory.insert(:post, category_ids: [cat1.id]),
      user: Factory.insert(:user),
      nsfw_post: Factory.insert(:post, %{is_adult_content: true}),
      nudity_post: Factory.insert(:post, %{has_nudity: true}),
    }
  end

  test "post/4 - id", %{post: post} do
    fetched_post = Content.post(post.id, current_user: nil, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
  end

  test "post/4 - token", %{post: post} do
    fetched_post = Content.post("~#{post.token}", current_user: nil, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.token == post.token
  end

  test "post/4 - id - with user", %{user: user, post: post} do
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user == nil
  end

  test "post/4 - includes reposted_source", %{user: user, post: post} do
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(repost.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == repost.id
    assert fetched_post.reposted_source.id == post.id
    assert fetched_post.reposted_source.reposted_source == nil
  end

  test "post/4 - includes assets", %{user: user, post: post} do
    asset1 = Factory.insert(:asset, %{post: post})
    asset2 = Factory.insert(:asset, %{post: post})
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert Enum.any?(fetched_post.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.assets, &(&1.id == asset2.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.assets
  end

  test "post/4 - includes assets for reposted source", %{user: user, post: post} do
    asset1 = Factory.insert(:asset, %{post: post})
    asset2 = Factory.insert(:asset, %{post: post})
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(repost.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset2.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.reposted_source.assets
  end

  test "post/4 - includes categories", %{user: user, post: post, category: cat} do
    cat_id = cat.id
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
    assert [%{id: ^cat_id}] = fetched_post.categories
  end

  test "post/4 - with user - does allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
  end

  test "post/4 - with user - does not allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: false, allow_nudity: false)
    refute fetched_post
  end

  test "post/4 - with user - does allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
  end

  test "post/4 - with user - does not allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: false, allow_nudity: false)
    refute fetched_post
  end

  test "post/4 - does not return blocked author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(blocked_post.id, current_user: user, allow_nsfw: false, allow_nudity: false)
    refute fetched_post
  end

  test "post/4 - does not return blocked repost author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    blocked_repost = Factory.insert(:post, %{reposted_source: blocked_post})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(blocked_repost.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    refute fetched_post
  end

  test "post/4 - does not return banned author" do
    banned_author = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    banned_post = Factory.insert(:post, %{author: banned_author})
    fetched_post = Content.post(banned_post.id, current_user: nil, allow_nsfw: true, allow_nudity: true)
    refute fetched_post
  end

  test "post/4 - does not return banned repost author" do
    banned_author = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    banned_post = Factory.insert(:post, %{author: banned_author})
    banned_repost = Factory.insert(:post, %{reposted_source: banned_post})
    fetched_post = Content.post(banned_repost.id, current_user: nil, allow_nsfw: true, allow_nudity: true)
    refute fetched_post
  end

  test "post/4 - does not return private author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    fetched_post = Content.post(private_post.id, current_user: nil, allow_nsfw: true, allow_nudity: true)
    refute fetched_post
  end

  test "post/4 - does not return private repost author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    private_repost = Factory.insert(:post, %{reposted_source: private_post})
    fetched_post = Content.post(private_repost.id, current_user: nil, allow_nsfw: true, allow_nudity: true)
    refute fetched_post
  end

  test "post/4 - with user - has reposted loved watching", %{user: user, post: post} do
    repost = Factory.insert(:post, %{author: user, reposted_source: post})
    love = Factory.insert(:love, %{post: post, user: user})
    watch = Factory.insert(:watch, %{post: post, user: user})
    fetched_post = Content.post(post.id, current_user: user, allow_nsfw: true, allow_nudity: true)
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user.id == repost.id
    assert fetched_post.love_from_current_user.id == love.id
    assert fetched_post.watch_from_current_user.id == watch.id
  end

  @tag :focus
  test "posts_by_user/2 - returns a page of results, and paginates", %{user: user} do
    author = Factory.insert(:user)
    now_date = DateTime.utc_now
    {:ok, earlier_date} = now_date
                  |> DateTime.to_unix
                  |> Kernel.-(3600)
                  |> DateTime.from_unix
    _posts = [
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: earlier_date}),
      Factory.insert(:post, %{author: author, created_at: DateTime.utc_now}),
      Factory.insert(:post, %{author: author, created_at: DateTime.utc_now}),
      Factory.insert(:post, %{author: author, created_at: DateTime.utc_now}),
    ]

    posts_page = Content.posts_by_user(author.id, current_user: user, allow_nsfw: true, allow_nudity: true, per_page: 3)
    assert %PostsPage{} = posts_page
    assert posts_page.total_pages == 3
    assert posts_page.total_count == 9
    assert posts_page.total_pages_remaining == 3
    assert posts_page.per_page == 3
    assert (Map.put(posts_page.before, :microsecond, 0)) == (Map.put(now_date, :microsecond, 0))

    posts_page = Content.posts_by_user(author.id, current_user: user, allow_nsfw: true, allow_nudity: true, per_page: 3, before: now_date)
    assert %PostsPage{} = posts_page
    assert posts_page.total_pages == 3
    assert posts_page.total_count == 9
    assert posts_page.total_pages_remaining == 2
    assert posts_page.per_page == 3
    assert (Map.put(posts_page.before, :microsecond, 0)) == (Map.put(earlier_date, :microsecond, 0))
  end

end
