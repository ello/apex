defmodule Ello.Core.ContentTest do
  use Ello.Core.Case
  alias Ello.Core.{Content, Image, Repo}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    cat1 = Factory.insert(:category)
    post = Factory.insert(:post)
    Factory.insert(:category_post, post: post, category: cat1)
    {:ok,
      category: cat1,
      post: post,
      user: Factory.insert(:user),
      nsfw_post: Factory.insert(:post, %{is_adult_content: true}),
      nudity_post: Factory.insert(:post, %{has_nudity: true}),
    }
  end

  test "post/1 - id", %{post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
  end

  test "post/1 - token", %{post: post} do
    fetched_post = Content.post(%{
      id_or_token:  "~#{post.token}",
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.token == post.token
  end

  test "post/1 - id - with user", %{user: user, post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user == nil
  end

  test "post/1 - includes reposted_source", %{user: user, post: post} do
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(%{
      id_or_token:  repost.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == repost.id
    assert fetched_post.reposted_source.id == post.id
    assert fetched_post.reposted_source.reposted_source == nil
  end

  test "post/1 - includes assets", %{user: user, post: post} do
    post = Factory.add_assets(post)
    [asset1, asset2] = post.assets
    unlinked_asset = Factory.insert(:asset, %{post: post})
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert Enum.any?(fetched_post.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.assets, &(&1.id == asset2.id))
    refute Enum.any?(fetched_post.assets, &(&1.id == unlinked_asset.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.assets
  end

  test "post/1 - includes assets for reposted source", %{user: user, post: post} do
    post = Factory.add_assets(post)
    [asset1, asset2] = post.assets
    unlinked_asset = Factory.insert(:asset, %{post: post})
    repost = Factory.insert(:post, %{reposted_source: post})
    fetched_post = Content.post(%{
      id_or_token:  repost.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset1.id))
    assert Enum.any?(fetched_post.reposted_source.assets, &(&1.id == asset2.id))
    refute Enum.any?(fetched_post.reposted_source.assets, &(&1.id == unlinked_asset.id))
    assert [%{attachment_struct: %Image{}}, %{attachment_struct: %Image{}}] = fetched_post.reposted_source.assets
  end

  test "post/1 - includes categories", %{user: user, post: post, category: cat} do
    cat_id = cat.id
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
    assert [%{id: ^cat_id}] = fetched_post.categories
  end

  test "post/1 - with user - does allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
  end

  test "post/1 - with user - does not allow nsfw", %{user: user, nsfw_post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   false,
      allow_nudity: false,
    })
    refute fetched_post
  end

  test "post/1 - with user - does allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
  end

  test "post/1 - with user - does not allow nudity", %{user: user, nudity_post: post} do
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   false,
      allow_nudity: false,
    })
    refute fetched_post
  end

  test "post/1 - does not return blocked author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(%{
      id_or_token:  blocked_post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - does not return blocked repost author", %{user: user} do
    blocked_author = Factory.insert(:user, %{})
    blocked_post = Factory.insert(:post, %{author: blocked_author})
    blocked_repost = Factory.insert(:post, %{reposted_source: blocked_post})
    user = Map.merge(user, %{all_blocked_ids: [blocked_author.id]})
    fetched_post = Content.post(%{
      id_or_token:  blocked_repost.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - does not return banned author" do
    banned_author = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    banned_post = Factory.insert(:post, %{author: banned_author})
    fetched_post = Content.post(%{
      id_or_token:  banned_post.id,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - returns banned author when current_user is_staff" do
    user = Factory.insert(:user, %{is_staff: true})
    banned_author = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    banned_post = Factory.insert(:post, %{author: banned_author})
    fetched_post = Content.post(%{
      id_or_token:  banned_post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post
  end

  test "post/1 - does not return banned repost author" do
    banned_author = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    banned_post = Factory.insert(:post, %{author: banned_author})
    banned_repost = Factory.insert(:post, %{reposted_source: banned_post})
    fetched_post = Content.post(%{
      id_or_token:  banned_repost.id,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - does not return private author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    fetched_post = Content.post(%{
      id_or_token:  private_post.id,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - does not return private repost author" do
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})
    private_repost = Factory.insert(:post, %{reposted_source: private_post})
    fetched_post = Content.post(%{
      id_or_token:  private_repost.id,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    refute fetched_post
  end

  test "post/1 - with user - has reposted loved watching", %{user: user, post: post} do
    repost = Factory.insert(:post, %{author: user, reposted_source: post})
    love = Factory.insert(:love, %{post: post, user: user})
    watch = Factory.insert(:watch, %{post: post, user: user})
    fetched_post = Content.post(%{
      id_or_token:  post.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert fetched_post.id == post.id
    assert fetched_post.repost_from_current_user.id == repost.id
    assert fetched_post.love_from_current_user.id == love.id
    assert fetched_post.watch_from_current_user.id == watch.id
  end

  test "posts/1 - by user - returns a page of posts", %{user: user} do
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
      Factory.insert(:post, %{author: author, created_at: now_date}),
      Factory.insert(:post, %{author: author, created_at: now_date}),
      Factory.insert(:post, %{author: author, created_at: now_date}),
    ]

    posts = Content.posts(%{
      user_id:      author.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
      per_page:     3,
      before:       nil,
    })
    assert Timex.diff(List.last(posts).created_at, now_date) < 1

    posts2 = Content.posts(%{
      user_id:      author.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
      per_page:     3,
      before:       now_date,
    })
    assert Timex.diff(List.last(posts2).created_at, earlier_date) < 1
  end

  test "posts/1 - by ids - does not include duplicates" do
    p1 = Factory.insert(:post)
    p2 = Factory.insert(:post)
    p3 = Factory.insert(:post)
    dup_ids = [p1.id, p2.id, p2.id, p2.id, p3.id]
    posts = Content.posts(%{
      ids:          dup_ids,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert [_, _, _] = posts
  end


  test "posts/1 - related to", _context do
    author = Factory.insert(:user)
    posts = Enum.map 1..10, fn (_) ->
      Factory.insert(:post, author: author)
    end
    other_post = Factory.insert(:post)
    comment1 = Factory.insert(:post, author: author, parent_post_id: other_post.id)
    comment2 = Factory.insert(:post, author: author, parent_post_id: other_post.id)
    comment3 = Factory.insert(:post, author: author, parent_post_id: other_post.id)
    post = Enum.random(posts)
    related = Content.posts(%{
      related_to:   post,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
      per_page:     5,
    })
    post_ids = Enum.map(posts, &(&1.id))
    related_ids = Enum.map(related, &(&1.id))
    assert [r1, r2, r3, r4, r5] = related_ids

    refute post.id in related_ids
    refute other_post.id in related_ids
    refute comment1.id in related_ids
    refute comment2.id in related_ids
    refute comment3.id in related_ids

    assert r1 in post_ids
    assert r2 in post_ids
    assert r3 in post_ids
    assert r4 in post_ids
    assert r5 in post_ids
  end

  test "comments/1 - returns all comments for a post" do
    post = Factory.insert(:post)
    post2 = Factory.insert(:post)
    comment1 = Factory.insert(:post, parent_post_id: post.id)
    comment2 = Factory.insert(:post, parent_post_id: post.id)
    comment3 = Factory.insert(:post, parent_post_id: post.id)
    comment4 = Factory.insert(:post, parent_post_id: post2.id)

    comments = Content.comments(%{
      post:         post,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     5,
      before:       nil,
    })

    comment_ids = Enum.map(comments, &(&1.id))
    assert comment1.id in comment_ids
    assert comment2.id in comment_ids
    assert comment3.id in comment_ids
    refute comment4.id in comment_ids

    assert [_, _] = Content.comments(%{
      post:         post,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     2,
      before:       nil,
    })
  end

  test "comments/1 - with reposts - returns all comments" do
    post = Factory.insert(:post)
    post2 = Factory.insert(:post)
    repost = Factory.insert(:post, reposted_source: post)
    comment1 = Factory.insert(:post, parent_post_id: post.id)
    comment2 = Factory.insert(:post, parent_post_id: post.id)
    comment3 = Factory.insert(:post, parent_post_id: repost.id)
    comment4 = Factory.insert(:post, parent_post_id: post2.id)

    comments = Content.comments(%{
      post:         post,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     5,
      before:       nil,
    })

    comment_ids = Enum.map(comments, &(&1.id))
    assert comment1.id in comment_ids
    assert comment2.id in comment_ids
    assert comment3.id in comment_ids
    refute comment4.id in comment_ids

    assert [_, _] = Content.comments(%{
      post:         post,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     2,
      before:       nil,
    })
  end

  test "comments/1 - when a reposts - returns all comments" do
    post = Factory.insert(:post)
    post2 = Factory.insert(:post)
    repost = Factory.insert(:post, reposted_source: post)
    comment1 = Factory.insert(:post, parent_post_id: post.id)
    comment2 = Factory.insert(:post, parent_post_id: post.id)
    comment3 = Factory.insert(:post, parent_post_id: repost.id)
    comment4 = Factory.insert(:post, parent_post_id: post2.id)

    comments = Content.comments(%{
      post:         repost,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     5,
      before:       nil,
    })

    comment_ids = Enum.map(comments, &(&1.id))
    assert comment1.id in comment_ids
    assert comment2.id in comment_ids
    assert comment3.id in comment_ids
    refute comment4.id in comment_ids

    assert [_, _] = Content.comments(%{
      post:         repost,
      current_user: nil,
      allow_nsfw:   false,
      allow_nudity: false,
      per_page:     2,
      before:       nil,
    })
  end

  test "loves/1 - returns all loved posts for a user", %{user: user} do
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post, has_nudity: true)
    post3 = Factory.insert(:post, is_adult_content: true, has_nudity: true)
    private_author = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_author})

    _love1 = Factory.insert(:love, %{post: post1, user: user, created_at: DateTime.from_unix!(1_000_000)})
    love2 = Factory.insert(:love, %{post: post2, user: user, created_at: DateTime.from_unix!(2_000_000)})
    love3 = Factory.insert(:love, %{post: post3, user: user, created_at: DateTime.from_unix!(3_000_000)})
    love4 = Factory.insert(:love, %{post: private_post, user: user, created_at: DateTime.from_unix!(4_000_000)})

    # Page 1
    assert [l3, l2] = Content.loves(%{
      user: user,
      current_user: nil,
      per_page: 2,
      allow_nsfw: true,
      allow_nudity: true,
    })
    assert [l3.post_id, l2.post_id] == [post3.id, post2.id]

    # Page 2
    assert [l1] = Content.loves(%{user: user, current_user: nil, per_page: 2, before: l2.created_at})
    assert [l1.post_id] == [post1.id]

    # All
    loves = Content.loves(%{
      user: user,
      current_user: nil,
      allow_nsfw: true,
      allow_nudity: true
    })

    # Don't include private
    refute love4.id in Enum.map(loves, &(&1.id))

    # Do include NSFW (and load the post)
    assert post3.id in Enum.map(loves, &(&1.post.id))

    # No NSFW
    loves = Content.loves(%{
      user: user,
      current_user: nil,
      allow_nsfw: false,
      allow_nudity: true,
    })

    # Don't includ nsfw loves
    refute love3.id in Enum.map(loves, &(&1.id))

    # No Nudity
    loves = Content.loves(%{
      user: user,
      current_user: nil,
      allow_nsfw: false,
      allow_nudity: false,
    })

    # Don't includ nudity loves
    refute love3.id in Enum.map(loves, &(&1.id))
    refute love2.id in Enum.map(loves, &(&1.id))
  end
end
