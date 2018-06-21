defmodule Ello.V3.Resolvers.UserLoveStreamTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    :ok
  end

  @query """
    query($username: String!, $perPage: String, $before: String) {
      userLoveStream(username: $username, perPage: $perPage, before: $before) {
        next
        isLastPage
        loves {
          id, user { id }, post { id, author { id } }
        }
      }
    }
  """

  test "It returns a user's loves", _ do
    user = Factory.insert(:user)
    love0 = Factory.insert(:love, %{user: user, deleted: true})
    love1 = Factory.insert(:love, %{user: user})
    love2 = Factory.insert(:love, %{user: user})
    love3 = Factory.insert(:love, %{user: user})

    resp = post_graphql(%{query: @query, variables: %{"username" => user.username, "perPage" => 4}})
    assert %{"data" => %{"userLoveStream" => json}} = json_response(resp)
    assert %{"loves" => loves, "next" => next, "isLastPage" => false} = json
    refute to_string(love0.id) in Enum.map(loves, &(&1["id"]))
    assert to_string(love3.id) in Enum.map(loves, &(&1["id"]))
    assert to_string(love2.id) in Enum.map(loves, &(&1["id"]))
    assert to_string(love1.id) in Enum.map(loves, &(&1["id"]))
    assert to_string(love3.user.id) in Enum.map(loves, &(&1["user"]["id"]))
    assert to_string(love2.user.id) in Enum.map(loves, &(&1["user"]["id"]))
    assert to_string(love1.user.id) in Enum.map(loves, &(&1["user"]["id"]))
    assert to_string(love3.post.author.id) in Enum.map(loves, &(&1["post"]["author"]["id"]))
    assert to_string(love2.post.author.id) in Enum.map(loves, &(&1["post"]["author"]["id"]))
    assert to_string(love1.post.author.id) in Enum.map(loves, &(&1["post"]["author"]["id"]))

    resp2 = post_graphql(%{query: @query, variables: %{"username" => user.username, "before" => next, "perPage" => 3}})
    assert %{"data" => %{"userLoveStream" => json2}} = json_response(resp2)
    assert %{"isLastPage" => true, "next" => _, "loves" => []} = json2
  end
end
