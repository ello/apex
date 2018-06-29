defmodule Ello.V3.Resolvers.SearchCategoriesTest do
  use Ello.V3.Case

  setup do
    cat1 = Factory.insert(:category, name: "Art", level: "primary", order: 1)
    cat2 = Factory.insert(:category, name: "Architecture", level: "secondary", order: 1)
    cat3 = Factory.insert(:category, name: "Not Art", level: nil)
    cat4 = Factory.insert(:category, name: "Abstract Art", level: "secondary", order: 2)
    cat5 = Factory.insert(:category, name: "differnt", level: "secondary", order: 3)
    cat6 = Factory.insert(:category, name: "meta", level: "meta")
    current_user = Factory.insert(:user)

    {:ok,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
      cat4: cat4,
      cat5: cat5,
      cat6: cat6,
      current_user: current_user,
    }
  end

  @query """
    query($query: String, $administered: Boolean) {
      searchCategories(query: $query, administered: $administered) {
        isLastPage
        categories {
          id
          name
          slug
          currentUserState { role }
        }
      }
    }
  """

  test "defaults to ordered categories with no args", %{
    cat1: cat1,
    cat2: cat2,
    cat4: cat4,
    cat5: cat5,
  } do
    resp = post_graphql(%{query: @query, variables: %{}})
    assert %{"data" => %{"searchCategories" => %{
      "categories" => json,
      "isLastPage" => true,
    }}} = json_response(resp)
    assert [c1, c2, c4, c5] = json
    assert c1["id"] == Integer.to_string(cat1.id)
    assert c2["id"] == Integer.to_string(cat2.id)
    assert c4["id"] == Integer.to_string(cat4.id)
    assert c5["id"] == Integer.to_string(cat5.id)
  end

  test "filters by query when present", %{
    cat1: cat1,
    cat2: cat2,
    cat4: cat4,
  } do
    resp = post_graphql(%{query: @query, variables: %{query: "ar"}})
    assert %{"data" => %{"searchCategories" => %{"categories" => json}}} = json_response(resp)
    assert [c1, c2, c4] = json
    assert c1["id"] == Integer.to_string(cat1.id)
    assert c2["id"] == Integer.to_string(cat2.id)
    assert c4["id"] == Integer.to_string(cat4.id)
  end

  test "filters by role when present", %{
    cat2: cat1,
    cat2: cat2,
    cat4: cat4,
    cat5: cat5,
    current_user: current_user,
  } do
    Factory.insert(:category_user, user: current_user, category: cat1, role: "featured")
    Factory.insert(:category_user, user: current_user, category: cat2, role: "curator")
    Factory.insert(:category_user, user: current_user, category: cat4, role: "curator")
    Factory.insert(:category_user, user: current_user, category: cat5, role: "moderator")
    resp = post_graphql(%{query: @query, variables: %{administered: true}}, current_user)
    assert %{"data" => %{"searchCategories" => %{"categories" => json}}} = json_response(resp)
    assert [c2, c4, c5] = json
    assert c2["id"] == Integer.to_string(cat2.id)
    assert c4["id"] == Integer.to_string(cat4.id)
    assert c5["id"] == Integer.to_string(cat5.id)
    assert c2["currentUserState"]["role"] === "CURATOR"
    assert c4["currentUserState"]["role"] === "CURATOR"
    assert c4["currentUserState"]["role"] === "MODERATOR"
  end

  test "filters by role and query when present", %{
    cat2: cat1,
    cat2: cat2,
    cat4: cat4,
    cat5: cat5,
    current_user: current_user,
  } do
    Factory.insert(:category_user, user: current_user, category: cat1, role: "featured")
    Factory.insert(:category_user, user: current_user, category: cat2, role: "curator")
    Factory.insert(:category_user, user: current_user, category: cat4, role: "curator")
    Factory.insert(:category_user, user: current_user, category: cat5, role: "moderator")
    resp = post_graphql(%{query: @query, variables: %{administered: true, query: "ar"}}, current_user)
    assert %{"data" => %{"searchCategories" => %{"categories" => json}}} = json_response(resp)
    assert [c2, c4] = json
    assert c2["id"] == Integer.to_string(cat2.id)
    assert c4["id"] == Integer.to_string(cat4.id)
    assert c2["currentUserState"]["role"] === "CURATOR"
    assert c4["currentUserState"]["role"] === "CURATOR"
  end

  test "filters by administered when present - no effect for staff", %{
    cat1: cat1,
    cat2: cat2,
    cat4: cat4,
    cat5: cat5,
  } do
    staff_user = Factory.insert(:user, is_staff: true)
    resp = post_graphql(%{query: @query, variables: %{administered: true}}, staff_user)
    assert %{"data" => %{"searchCategories" => %{"categories" => json}}} = json_response(resp)
    assert [c1, c2, c4, c5] = json
    assert c1["id"] == Integer.to_string(cat1.id)
    assert c2["id"] == Integer.to_string(cat2.id)
    assert c4["id"] == Integer.to_string(cat4.id)
    assert c5["id"] == Integer.to_string(cat5.id)
  end
end
