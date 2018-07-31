defmodule Ello.V3.Resolvers.SearchUsersTest do
  use Ello.V3.Case
  alias Ello.Search.User.Index

  setup do
    current_user = Factory.insert(:user)
    user1 = Factory.insert(:user, username: "testing")
    user2 = Factory.insert(:user, username: "test")
    user3 = Factory.insert(:user, username: "tester")
    user4 = Factory.insert(:user, username: "testable")
    user5 = Factory.insert(:user, username: "test-test")
    user6 = Factory.insert(:user, username: "nope")

    Index.delete
    Index.create
    Enum.each([user1, user2, user3, user4, user5, user6], &Index.add/1)

    {:ok, %{
      current_user: current_user,
      user1: user1,
      user2: user2,
      user3: user3,
      user4: user4,
      user5: user5,
      user6: user6,
    }}
  end

  @autocomplete_query """
    query($query: String, $perPage: Int) {
      searchUsers(query: $query, perPage: $perPage) {
        users { id username }
      }
    }
  """

  test "autocomplete", %{
    user1: user1,
    user2: user2,
    user3: user3,
    user4: user4,
    user5: user5,
    user6: user6,
    current_user: current_user
  } do
    resp = post_graphql(%{query: @autocomplete_query, variables: %{query: "test"}}, current_user)
    assert %{"data" => %{"searchUsers" => %{
      "users" => users,
    }}} = json_response(resp)
    ids = Enum.map(users, &(&1["id"]))
    assert Integer.to_string(user1.id) in ids
    assert Integer.to_string(user2.id) in ids
    assert Integer.to_string(user3.id) in ids
    assert Integer.to_string(user4.id) in ids
    assert Integer.to_string(user5.id) in ids
    refute Integer.to_string(user6.id) in ids
  end
end
