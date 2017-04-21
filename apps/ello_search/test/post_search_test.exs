defmodule Ello.Search.PostSearchTest do
  use Ello.Search.Case
  alias Ello.Search.{PostIndex, PostSearch}
  alias Ello.Core.{Repo, Factory, Network}
  require IEx

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    current_user = Factory.insert(:user)
    post         = Factory.insert(:post)
    irrel_post   = Factory.insert(:post, %{body: [%{"data" => "Irrelevant post!", "kind" => "text"}]})
    comment      = Factory.insert(:comment)
    repost       = Factory.insert(:repost)
    flagged_post = Factory.insert(:post)
    nsfw_post    = Factory.insert(:post, %{is_adult_content: true})
    nudity_post  = Factory.insert(:post, %{has_nudity: true})
    private_user = Factory.insert(:user, %{is_public: false})
    private_post = Factory.insert(:post, %{author: private_user})
    locked_user  = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    locked_post  = Factory.insert(:post, %{author: locked_user})
    spam_post    = Factory.insert(:post)
    hashtag_post = Factory.insert(:post, %{body: [%{"data" => "#phrasing", "kind" => "text"}]})
    mention_post = Factory.insert(:post, %{body: [%{"data" => "@archer", "kind" => "text"}]})
    badman_post  = Factory.insert(:post, %{body: [%{"data" => "This is a bad, bad man.", "kind" => "text"}]})

    PostIndex.delete
    PostIndex.create
    PostIndex.add(post)
    PostIndex.add(irrel_post)
    PostIndex.add(comment)
    PostIndex.add(repost)
    PostIndex.add(flagged_post, %{post: %{is_hidden: true}})
    PostIndex.add(nsfw_post)
    PostIndex.add(nudity_post)
    PostIndex.add(private_post)
    PostIndex.add(locked_post)
    PostIndex.add(spam_post, %{author: %{is_spammer: true}})

    {:ok,
      current_user: current_user,
      post: post,
      irrel_post: irrel_post,
      comment: comment,
      repost: repost,
      flagged_post: flagged_post,
      nsfw_post: nsfw_post,
      nudity_post: nudity_post,
      private_post: private_post,
      private_user: private_user,
      locked_post: locked_post,
      spam_post: spam_post,
      hashtag_post: hashtag_post,
      mention_post: mention_post,
      badman_post: badman_post,
    }
  end

  test "post_search - returns a relevant result", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.irrel_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return comments", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.comment.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return flagged (hidden) posts", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.flagged_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return nsfw posts if the client disallows", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.nsfw_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - returns nsfw posts if the client allows", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: true, allow_nudity: false})
    assert context.post.id in Enum.map(results, &(&1.id))
    assert context.nsfw_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return nudity posts if the client disallows", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.nudity_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - returns nudity posts if the client allows", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: true})
    assert context.post.id in Enum.map(results, &(&1.id))
    assert context.nudity_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return posts with a private author if no current_user", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.private_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return posts with a locked author", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.locked_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not return posts with a spam author", context do
    results = PostSearch.post_search("Phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.post.id
    refute context.spam_post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - paginates successfully", context do
    results = PostSearch.post_search("Phrasing", %{allow_nsfw: true, allow_nudity: true, current_user: nil})
    assert length(Enum.map(results, &(&1.id))) == 3

    results = PostSearch.post_search("Phrasing", %{allow_nsfw: true, allow_nudity: true, current_user: nil, page: 0, per_page: 2})
    assert length(Enum.map(results, &(&1.id))) == 2

    results = PostSearch.post_search("Phrasing", %{allow_nsfw: true, allow_nudity: true, current_user: nil, page: 1, per_page: 2})
    assert length(Enum.map(results, &(&1.id))) == 1

    results = PostSearch.post_search("Phrasing", %{allow_nsfw: true, allow_nudity: true, current_user: nil, page: 2, per_page: 2})
    assert length(Enum.map(results, &(&1.id))) == 0
  end

  test "post_search - boosts hashtags", context do
    PostIndex.add(context.hashtag_post)
    results = PostSearch.post_search("phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.hashtag_post.id
    assert context.post.id in Enum.map(results, &(&1.id))
    assert length(Enum.map(results, &(&1.id))) == 2
  end

  test "post_search - also finds posts if hashtags are used in terms", context do
    PostIndex.add(context.hashtag_post)
    results = PostSearch.post_search("#phrasing", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.hashtag_post.id
    assert context.post.id in Enum.map(results, &(&1.id))
    assert length(Enum.map(results, &(&1.id))) == 2
  end

  test "post_search - matches on mentions", context do
    PostIndex.add(context.mention_post)
    results = PostSearch.post_search("@archer", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.mention_post.id
    assert length(Enum.map(results, &(&1.id))) == 1
  end

  test "post_search - handles encoded terms correctly", context do
    PostIndex.add(context.badman_post)
    results = PostSearch.post_search("bad%20AND%20man%20", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.badman_post.id
    assert length(Enum.map(results, &(&1.id))) == 1
  end

  test "post_search - does not throw exceptions when logic operators end the terms", context do
    PostIndex.add(context.badman_post)
    results = PostSearch.post_search("bad%20%20%20AND%20%20%20", %{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert hd(results).id == context.badman_post.id
    assert length(Enum.map(results, &(&1.id))) == 1
  end

  test "post_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.private_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = PostSearch.post_search("phrasing", %{allow_nsfw: false, allow_nudity: false, current_user: current_user})
    refute context.private_post.id in Enum.map(results, &(&1.id))
    assert context.post.id in Enum.map(results, &(&1.id))
  end

  test "post_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.private_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = PostSearch.post_search("phrasing", %{allow_nsfw: false, allow_nudity: false, current_user: current_user})
    refute context.private_post.id in Enum.map(results, &(&1.id))
    assert context.post.id in Enum.map(results, &(&1.id))
  end

  test "trending - returns a relevant result", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    assert context.irrel_post.id in Enum.map(results, &(&1.id))
    assert context.post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return comments", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.comment.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return flagged (hidden) posts", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.flagged_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return nsfw posts if the client disallows", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.nsfw_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - returns nsfw posts if the client allows", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: true, allow_nudity: false})
    assert context.nsfw_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return nudity posts if the client disallows", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.nudity_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - returns nudity posts if the client allows", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: true})
    assert context.nudity_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return posts with a private author if no current_user", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.private_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - returns private posts if there is a current_user", context do
    results = PostSearch.trending(%{current_user: context.current_user, allow_nsfw: false, allow_nudity: false})
    assert context.private_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return posts with a locked author", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.locked_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not return posts with a spam author", context do
    results = PostSearch.trending(%{current_user: nil, allow_nsfw: false, allow_nudity: false})
    refute context.spam_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.private_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = PostSearch.trending(%{allow_nsfw: false, allow_nudity: false, current_user: current_user})
    refute context.private_post.id in Enum.map(results, &(&1.id))
  end

  test "trending - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.private_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = PostSearch.trending(%{allow_nsfw: false, allow_nudity: false, current_user: current_user})
    refute context.private_post.id in Enum.map(results, &(&1.id))
  end
end
