defmodule Ello.V3.Resolvers.CategoryTest do
  use Ello.V3.Case

  setup do
    cat1 = Factory.insert(:category, level: "secondary", id: 3)
    cu1 = Factory.insert(:category_user, category: cat1, role: "featured")
    cu2 = Factory.insert(:category_user, category: cat1, role: "curator")
    cu3 = Factory.insert(:category_user, category: cat1, role: "moderator")

    {:ok,
      cat1: cat1,
      cu1: cu1,
      cu2: cu2,
      cu3: cu3,
    }
  end

  test "Returns the category", %{cat1: cat1} do
    query = """
    {
      category(slug: "#{cat1.slug}") {
          id
          name
          slug
          level
          order
          tile_image {
            small {
              url
              metadata {
                width
                height
                size
                type
              }
            }
          }
        }
    }
    """

    resp = post_graphql(%{query: query})
    assert %{"data" => %{"category" => json}} = json_response(resp)
    assert json["id"] == "#{cat1.id}"
  end

  test "Returns the category with users", %{cat1: cat1, cu2: cu2, cu2: cu3} do
    query = """
      query($slug: String, $roles: [CategoryUserRole]) {
        category(slug: $slug) {
          id
          slug
          categoryUsers(roles: $roles) {
            id
            role
            user {
              id
              username
            }
          }
        }
      }
    """

    resp = post_graphql(%{
      query: query,
      variables: %{slug: cat1.slug, roles: ["CURATOR", "MODERATOR"]},
    })
    assert %{"data" => %{"category" => json}} = json_response(resp)
    assert json["id"] == "#{cat1.id}"
    assert [_jcu2, _jcu3] = users = json["categoryUsers"]

    assert "#{cu2.id}" in Enum.map(users, &(&1["id"]))
    assert "#{cu3.id}" in Enum.map(users, &(&1["id"]))
    assert "CURATOR" in Enum.map(users, &(&1["role"]))
    assert "MODERATOR" in Enum.map(users, &(&1["role"]))
    assert cu2.user.username in Enum.map(users, &(&1["user"]["username"]))
    assert cu3.user.username in Enum.map(users, &(&1["user"]["username"]))
  end
end
