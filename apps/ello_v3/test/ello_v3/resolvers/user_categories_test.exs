defmodule Ello.V3.Resolvers.UserCategoriesTest do
  use Ello.V3.Case

  setup do
    cat1 = Factory.insert(:category, level: "primary", id: 3)
    cat2 = Factory.insert(:category, level: "primary", id: 4)
    cat3 = Factory.insert(:category, level: "primary", id: 5)
    user = Factory.insert(:user, followed_category_ids: [cat1.id, cat2.id])

    {:ok,
      user: user,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
    }
  end

  test "Returns followed categories when there is a current_user", context do
    query = """
    {
      categoryNav {
          id
          name
          slug
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

    resp = post_graphql(%{query: query}, context.user)
    assert %{"data" => %{"categoryNav" => json}} = json_response(resp)
    assert to_string(context.cat1.id) in Enum.map(json, &(&1["id"]))
    assert to_string(context.cat2.id) in Enum.map(json, &(&1["id"]))
    refute to_string(context.cat3.id) in Enum.map(json, &(&1["id"]))
  end

  test "Returns primary categories when there is a current_user", context do
    query = """
    {
      categoryNav {
          id
          name
          slug
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
    assert %{"data" => %{"categoryNav" => json}} = json_response(resp)
    assert to_string(context.cat1.id) in Enum.map(json, &(&1["id"]))
    assert to_string(context.cat2.id) in Enum.map(json, &(&1["id"]))
    assert to_string(context.cat3.id) in Enum.map(json, &(&1["id"]))

    assert to_string(context.cat1.name) in Enum.map(json, &(&1["name"]))
    assert to_string(context.cat2.name) in Enum.map(json, &(&1["name"]))
    assert to_string(context.cat3.name) in Enum.map(json, &(&1["name"]))

    assert to_string(context.cat1.slug) in Enum.map(json, &(&1["slug"]))
    assert to_string(context.cat2.slug) in Enum.map(json, &(&1["slug"]))
    assert to_string(context.cat3.slug) in Enum.map(json, &(&1["slug"]))

    assert length(Enum.map(json, &(&1["tile_image"]))) === 3
  end
end
