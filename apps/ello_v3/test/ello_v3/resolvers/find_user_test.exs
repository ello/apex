defmodule Ello.V3.Resolvers.FindUserTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user = Factory.insert(:user, username: "gql")
    cat1 = Factory.insert(:category)
    Factory.insert(:category_user, user: user, category: cat1, role: "featured")
    cat2 = Factory.insert(:category)
    Factory.insert(:category_user, user: user, category: cat2, role: "curator")
    cat3 = Factory.insert(:category)
    Factory.insert(:category_user, user: user, category: cat3, role: "moderator")

    {:ok, user: user, categories: [cat1, cat2, cat3]}
  end

  test "Full user representation - by username", %{user: user, categories: [c1, c2, c3]} do
    query = """
      query($username: String!) {
        findUser(username: $username) {
          id
          username
          name
          location
          formattedShortBio
          isCommunity
          badges
          currentUserState { relationshipPriority }
          externalLinksList { icon type text url }
          userStats {
            followingCount
            followersCount
            lovesCount
            postsCount
            totalViewsCount
          }
          settings {
            postsAdultContent
            hasCommentingEnabled
            hasRepostingEnabled
            hasLovesEnabled
            isHireable
            isCollaborateable
          }
          categoryUsers {
            id
            role
            category { id name slug }
          }
        }
      }
    """

    resp = post_graphql(%{query: query, variables: %{username: user.username}})
    assert %{"data" => %{"findUser" => json}} = json_response(resp)

    assert json["id"] == "#{user.id}"
    assert json["username"] == user.username
    assert json["userStats"]["postsCount"]
    assert json["settings"]["hasCommentingEnabled"]

    assert [j1, j2, j3] = json["categoryUsers"]
    assert j1["role"] == "FEATURED"
    assert j1["category"]["name"] == c1.name
    assert j2["role"] == "CURATOR"
    assert j2["category"]["name"] == c2.name
    assert j3["role"] == "MODERATOR"
    assert j3["category"]["name"] == c3.name
  end
end
