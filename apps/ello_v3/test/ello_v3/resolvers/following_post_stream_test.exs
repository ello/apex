defmodule Ello.V3.Resolvers.FollowingPostStreamTest do
  use Ello.V3.Case
  alias Ello.Stream
  alias Ello.Stream.Item
  alias Ello.Search.Post.Index
  alias Ello.Core.Redis

  @query """
    query($kind: StreamKind!, $perPage: String, $before: String) {
      followingPostStream(kind: $kind, before: $before, perPage: $perPage) {
        next
        isLastPage
        posts {
          id
          author { id }
        }
      }
    }
  """

  @new_content_query """
    query($kind: StreamKind!, $since: String) {
      newFollowingPostStreamContent(kind: $kind, since: $since) {
        newContent
      }
    }
  """


  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Ello.Core.Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    current_user = Factory.insert(:user)

    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
    post0 = Factory.insert(:post, author: current_user)
    post1 = Factory.insert(:post, author: user1)
    post2 = Factory.insert(:post, author: user2)
    post3 = Factory.insert(:post, author: user1)
    post4 = Factory.insert(:post, author: user2)

    roshi_items = [
      %Item{id: "#{post0.id}", stream_id: "#{current_user.id}", ts: DateTime.utc_now},
      %Item{id: "#{post1.id}", stream_id: "#{user1.id}", ts: DateTime.utc_now},
      %Item{id: "#{post2.id}", stream_id: "#{user2.id}", ts: DateTime.utc_now},
      %Item{id: "#{post3.id}", stream_id: "#{user1.id}", ts: DateTime.utc_now},
      %Item{id: "#{post4.id}", stream_id: "#{user2.id}", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    on_exit fn() ->
      Redis.command(["DEL", "user:#{current_user.id}:followed_users_id_cache"])
    end

    {:ok, %{
      current_user: current_user,
      users: [user1, user2],
      posts: [post0, post1, post2, post3, post4],
    }}
  end

  test "Recent - Returns an error when requesting the stream when not logged in" do
    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "RECENT",
      "perPage" => 3,
    }})
    assert %{"errors" => [%{"message" => "unauthenticated"} | _]} = json_response(resp)
  end

  test "Recent - Returns an empty post stream with no posts" do
    current_user = Factory.insert(:user)
    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "RECENT",
      "perPage" => 3,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json
  end

  test "Recent - Returns a recen tpost stream when posts exist", %{
    current_user: current_user,
    users: users
  } do
    [u1, u2] = users
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u1.id])
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u2.id])

    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "RECENT",
      "perPage" => 3,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => [_p1, _p2, _p3]} = json

    resp2 = post_graphql(%{query: @query, variables: %{
      "kind" => "RECENT",
      "before" => next,
      "perPage" => 5,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "posts" => [_p4, _p5]} = json2
  end

  test "Recent New? - checking for new content - no new content", %{
    current_user: current_user,
    users: users,
  } do
    [u1, u2] = users
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u1.id])
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u2.id])

    resp = post_graphql(%{query: @new_content_query, variables: %{
      "kind" => "RECENT",
      "since" => DateTime.to_iso8601(DateTime.utc_now()),
    }}, current_user)
    assert %{"data" => %{"newFollowingPostStreamContent" => json}} = json_response(resp)
    assert %{"newContent" => false} = json
  end

  test "Recent New? - checking for new content - new content", %{
    current_user: current_user,
    users: users,
  } do
    [u1, u2] = users
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u1.id])
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u2.id])

    resp = post_graphql(%{query: @new_content_query, variables: %{
      "kind" => "RECENT",
      "since" => DateTime.to_iso8601(Timex.beginning_of_day(DateTime.utc_now())),
    }}, current_user)
    assert %{"data" => %{"newFollowingPostStreamContent" => json}} = json_response(resp)
    assert %{"newContent" => true} = json
  end

  test "Trending - Returns an error when requesting the stream when not logged in" do
    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "TRENDING",
      "perPage" => 3,
    }})
    assert %{"errors" => [%{"message" => "unauthenticated"} | _]} = json_response(resp)
  end

  test "Trending - Returns an empty post stream with no posts" do
    current_user = Factory.insert(:user)
    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "TRENDING",
      "perPage" => 3,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => true, "next" => _, "posts" => []} = json
  end

  test "Trending - Returns a recent post stream when posts exist", %{
    current_user: current_user,
    users: users,
    posts: posts,
  } do
    [u1, u2] = users
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u1.id])
    Redis.command(["SADD", "user:#{current_user.id}:followed_users_id_cache", u2.id])
    Enum.each(posts, &Index.add/1)

    resp = post_graphql(%{query: @query, variables: %{
      "kind" => "TRENDING",
      "perPage" => 3,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json}} = json_response(resp)
    assert %{"isLastPage" => false, "next" => next, "posts" => [_p1, _p2, _p3]} = json

    resp2 = post_graphql(%{query: @query, variables: %{
      "kind" => "TRENDING",
      "before" => next,
      "perPage" => 5,
    }}, current_user)
    assert %{"data" => %{"followingPostStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "posts" => _} = json2
  end
end
