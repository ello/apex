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
          brand_account { id }
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

    all_ids = Enum.map(json, &(&1["id"]))
    all_names = Enum.map(json, &(&1["name"]))
    all_slugs = Enum.map(json, &(&1["slug"]))

    assert to_string(context.cat1.id) in all_ids
    assert to_string(context.cat2.id) in all_ids
    refute to_string(context.cat3.id) in all_ids
    refute to_string(context.cat4.id) in all_ids

    assert to_string(context.cat1.name) in all_names
    assert to_string(context.cat2.name) in all_names

    assert to_string(context.cat1.slug) in all_slugs
    assert to_string(context.cat2.slug) in all_slugs

    assert hd(json)["brand_account"] == nil

    assert length(Enum.map(json, &(&1["tile_image"]))) === 2
  end
end
