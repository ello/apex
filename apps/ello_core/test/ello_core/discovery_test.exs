defmodule Ello.Core.DiscoveryTest do
  use Ello.Core.Case
  alias Ello.Core.Image

  setup do
    {:ok,
      inactive: Factory.insert(:category, level: nil, order: nil),
      active1:  Factory.insert(:category, level: "primary", order: 2),
      active2:  Factory.insert(:category, level: "primary", order: 1),
      meta:     Factory.insert(:category, level: "meta", order: 1, slug: "fu"),
      user:     Factory.insert(:user),
    }
  end

  test "category/1 - slug", %{meta: meta, user: user} do
    category = Discovery.category(%{
      id_or_slug:   meta.slug,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    assert category.id == meta.id
    assert %Image{} = category.tile_image_struct
  end

  test "category/1 - id", %{meta: meta, user: user} do
    category = Discovery.category(%{
      id_or_slug:   meta.id,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
      promotionals: true,
    })
    assert category.id == meta.id
    assert %Image{} = category.tile_image_struct
  end

  test "category/1 - promotionals: false, images: false", %{meta: meta, user: user} do
    category = Discovery.category(%{
      id_or_slug:   meta.slug,
      current_user: user,
      allow_nsfw:   true,
      allow_nudity: true,
      images:       false,
      promotionals: false,
    })
    assert category.id == meta.id
    refute category.tile_image_struct
    assert %Ecto.Association.NotLoaded{} = category.promotionals
  end

  test "categories/1", context do
    cats = Discovery.categories(%{
      current_user: context.user,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    refute context.inactive.id in cat_ids
    refute context.meta.id     in cat_ids
    assert [context.active2.id, context.active1.id] == cat_ids
    assert %Image{} = hd(cats).tile_image_struct
  end

  test "categories/1 - meta: true", context do
    cats = Discovery.categories(%{
      current_user: context.user,
      allow_nsfw:   true,
      allow_nudity: true,
      meta:         true,
    })
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    refute context.inactive.id in cat_ids
    assert context.meta.id     in cat_ids
    assert %Image{} = hd(cats).tile_image_struct
  end

  test "categories/1 - inactive: true", context do
    cats = Discovery.categories(%{
      current_user: context.user,
      allow_nsfw:   true,
      allow_nudity: true,
      inactive:     true,
    })
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    assert context.inactive.id in cat_ids
    refute context.meta.id     in cat_ids
    assert %Image{} = hd(cats).tile_image_struct
  end

  test "categories/1 - inactive: true, meta: true", context do
    cats = Discovery.categories(%{
      current_user: context.user,
      allow_nsfw:   true,
      allow_nudity: true,
      inactive:     true,
      meta:         true,
    })
    cat_ids = Enum.map(cats, &(&1.id))
    assert context.active1.id  in cat_ids
    assert context.active2.id  in cat_ids
    assert context.inactive.id in cat_ids
    assert context.meta.id     in cat_ids
    assert %Image{} = hd(cats).tile_image_struct
  end

  test "categories/1 - ids: [], promotionals: false, images: true", context do
    [cat] = Discovery.categories(%{
      ids: [context.active1.id, context.inactive.id],
      current_user: nil,
      images: true,
    })
    assert context.active1.id == cat.id
    assert cat.tile_image_struct
    assert %Ecto.Association.NotLoaded{} = cat.promotionals
  end

  test "categories/1 - ids: [], promotionals: false, images: false", context do
    [cat] = Discovery.categories(%{
      ids: [context.active1.id, context.inactive.id],
      current_user: nil,
      images: false
    })
    assert context.active1.id == cat.id
    refute cat.tile_image_struct
    assert %Ecto.Association.NotLoaded{} = cat.promotionals
  end
end
