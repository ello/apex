defmodule Ello.V3.Resolvers.UserNetworkStreamTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    boring = Factory.insert(:user)
    interesting = Factory.insert(:user)

    users_with_offset = Factory.insert_list(10, :user)
    Enum.each(users_with_offset |> Enum.with_index, fn({user, offset}) ->
      Factory.insert(:relationship, subject: user, owner: boring, priority: "friend", created_at: FactoryTime.now_offset(offset))
      Factory.insert(:relationship, subject: interesting, owner: user, priority: "friend", created_at: FactoryTime.now_offset(offset))
    end)

    {:ok, %{
      interesting: interesting,
      boring: boring,
    }}
  end

  @query """
    query($kind: RelationshipKind!, $username: String, $id: String, $before: String, $perPage: Int) {
      userNetworkStream(kind: $kind, before: $before, perPage: $perPage, username: $username, id: $id) {
        next
        isLastPage
        users {
          id
          username
          location
          name
          currentUserState { relationshipPriority }
          avatar {
            original { url }
          }
          badges
          userStats {
            followersCount
            followingCount
            lovesCount
            postsCount
            totalViewsCount
          }
        }
      }
    }
  """

  test "Target user not found", %{} do
    resp = post_graphql(%{query: @query, variables: %{username: "NOPE", kind: "FOLLOWING"}})
    assert %{"errors" => [%{"message" => msg} | _]} = json_response(resp)
    assert msg == "User not found"
  end

  test "No followers", %{boring: boring} do
    resp = post_graphql(%{query: @query, variables: %{username: boring.username, kind: "FOLLOWERS"}})
    assert %{"data" => %{"userNetworkStream" => json}} = json_response(resp)
    assert %{"users" => [], "isLastPage" => true, "next" => _} = json
  end

  test "followers by id", %{interesting: interesting} do
    resp = post_graphql(%{
      query: @query,
      variables: %{
        id: interesting.id,
        kind: "FOLLOWERS",
        perPage: 3,
      }
    })
    assert %{"data" => %{"userNetworkStream" => json}} = json_response(resp)
    assert %{"users" => users, "isLastPage" => false, "next" => next} = json
    assert length(users) == 3
    user1 = hd(users)
    assert user1["id"]
    assert user1["username"]
    assert user1["currentUserState"]["relationshipPriority"] == "friend"
    assert user1["avatar"]
    assert user1["badges"]
    assert user1["userStats"]["followersCount"] == 0
    assert user1["userStats"]["followingCount"] == 0
    assert user1["userStats"]["lovesCount"] == 0
    assert user1["userStats"]["postsCount"] == 0
    assert user1["userStats"]["totalViewsCount"] == 0

    resp2 = post_graphql(%{
      query: @query,
      variables: %{
        id: interesting.id,
        kind: "FOLLOWERS",
        perPage: 10,
        before: next,
      }
    })
    assert %{"data" => %{"userNetworkStream" => json2}} = json_response(resp2)
    assert %{"users" => users2, "isLastPage" => true, "next" => _} = json2
    assert length(users2) == 7
  end

  test "followers by username", %{interesting: interesting} do
    resp = post_graphql(%{
      query: @query,
      variables: %{
        username: interesting.username,
        kind: "FOLLOWERS",
        perPage: 3,
      }
    })
    assert %{"data" => %{"userNetworkStream" => json}} = json_response(resp)
    assert %{"users" => users, "isLastPage" => false, "next" => _next} = json
    assert length(users) == 3
  end
end
