defmodule Ello.V3.Resolvers.CategoriesTest do
  use Ello.V3.Case

  setup do
    cat1 = Factory.insert(:category, level: "primary", id: 3)
    cat2 = Factory.insert(:category, level: "secondary", id: 4)
    cat3 = Factory.insert(:category, level: nil, id: 5)
    cat4 = Factory.insert(:category, level: "meta", id: 6)

    {:ok,
      cat1: cat1,
      cat2: cat2,
      cat3: cat3,
      cat4: cat4,
    }
  end

  test "Returns all active categories", context do
    query = """
    {
      allCategories {
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
    assert %{"data" => %{"allCategories" => json}} = json_response(resp)
    assert to_string(context.cat1.id) in Enum.map(json, &(&1["id"]))
    assert to_string(context.cat2.id) in Enum.map(json, &(&1["id"]))
    refute to_string(context.cat3.id) in Enum.map(json, &(&1["id"]))
    refute to_string(context.cat4.id) in Enum.map(json, &(&1["id"]))

    assert to_string(context.cat1.name) in Enum.map(json, &(&1["name"]))
    assert to_string(context.cat2.name) in Enum.map(json, &(&1["name"]))

    assert to_string(context.cat1.slug) in Enum.map(json, &(&1["slug"]))
    assert to_string(context.cat2.slug) in Enum.map(json, &(&1["slug"]))

    assert length(Enum.map(json, &(&1["tile_image"]))) === 2
  end
end
