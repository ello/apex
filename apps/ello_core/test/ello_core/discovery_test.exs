defmodule Ello.Core.DiscoveryTest do
  use Ello.Core.Case

  setup do
    {:ok,
      inactive: Factory.insert(:category, level: nil, order: nil),
      active1:  Factory.insert(:category, level: "primary", order: 2),
      active2:  Factory.insert(:category, level: "primary", order: 1),
      meta:     Factory.insert(:category, level: "meta", order: 1, slug: "fu"),
      user:     Factory.insert(:user),
    }
  end

  test "category/2 - slug", %{meta: meta, user: user} do
    assert Discovery.category(meta.slug, user).id == meta.id
  end

  test "category/2 - id", %{meta: meta, user: user} do
    assert Discovery.category(meta.id, user).id == meta.id
  end

  test "categories/1", context do
    cats = Discovery.categories(context.user)
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    refute context.inactive.id in cat_ids
    refute context.meta.id     in cat_ids
    assert [context.active2.id, context.active1.id] == cat_ids
  end

  test "categories/2 - meta: true", context do
    cats = Discovery.categories(context.user, meta: true)
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    refute context.inactive.id in cat_ids
    assert context.meta.id     in cat_ids
  end

  test "categories/2 - inactive: true", context do
    cats = Discovery.categories(context.user, inactive: true)
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    assert context.inactive.id in cat_ids
    refute context.meta.id     in cat_ids
  end

  test "categories/2 - inactive: true, meta: true", context do
    cats = Discovery.categories(context.user, inactive: true, meta: true)
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    assert context.inactive.id in cat_ids
    assert context.meta.id     in cat_ids
  end

  test "categories_by_ids/1", context do
    cats = Discovery.categories_by_ids([context.active1.id, context.inactive.id])
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    refute context.inactive.id in cat_ids
  end
end
