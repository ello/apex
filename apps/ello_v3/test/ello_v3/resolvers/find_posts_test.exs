defmodule Ello.V3.Resolvers.FindPostsTest do
  use Ello.V3.Case

  test "Abbreviated post representation" do
    p1 = Factory.insert(:post)
    p2 = Factory.insert(:post)
    query = """
      query($tokens: [String]) {
        findPosts(tokens: $tokens) {
          id
          token
        }
      }
    """

    resp = post_graphql(%{query: query, variables: %{tokens: [p1.token, p2.token]}})
    assert %{"data" => %{"findPosts" => [j1, j2]}} = json_response(resp)
    assert j1["id"] == "#{p1.id}"
    assert j2["id"] == "#{p2.id}"
  end
end
