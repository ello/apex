defmodule Ello.V2.EditorialViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.EditorialView
  alias Ello.Core.Discovery.Editorial

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "editorial.json - post kind", context do
    editorial = Editorial.build_images(Factory.insert(:post_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "post"
    assert json[:title]
    assert json[:subtitle]
    refute json[:url]
    assert json[:links][:post] == %{
      href: "/api/v2/posts/#{editorial.post.id}",
      id:   "#{editorial.post.id}",
      type: "posts",
    }
  end

  test "editorial.json - external kind", context do
    editorial = Editorial.build_images(Factory.insert(:external_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "external"
    assert json[:title]
    assert json[:subtitle]
    assert json[:url]
    refute json[:links]
  end

  test "editorial.json - curated posts kind", context do
    editorial = Editorial.build_images(Factory.insert(:curated_posts_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "post_stream"
    assert json[:title]
    refute json[:subtitle]
    refute json[:url]
    assert json[:links][:post_stream][:type] == "posts"
    assert json[:links][:post_stream][:href]
  end

  test "editorial.json - category kind", context do
    editorial = Editorial.build_images(Factory.insert(:category_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "post_stream"
    assert json[:title]
    refute json[:subtitle]
    refute json[:url]
    assert json[:links][:post_stream][:type] == "posts"
    assert json[:links][:post_stream][:href]
  end

  test "editorial.json - images", context do
    editorial = Editorial.build_images(Factory.insert(:post_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert %{
      "original" => %{
        url: "https://assets.ello.co/uploads/editorial/one_by_one_image/" <> _,
      },
      "optimized" => %{
        url: _,
        metadata: %{size: _, height: _, width: _, type: _},
      },
      "xhdpi" => %{
        url: _,
        metadata: %{size: _, height: _, width: _, type: _},
      },
      "hdpi" => %{
        url: _,
        metadata: %{size: _, height: _, width: _, type: _},
      },
      "mdpi" => %{
        url: _,
        metadata: %{size: _, height: _, width: _, type: _},
      },
      "ldpi" => %{
        url: _,
        metadata: %{size: _, height: _, width: _, type: _},
      },
    } = json[:one_by_one_image]

    assert %{
      "original" => %{
        url: "https://assets.ello.co/uploads/editorial/one_by_two_image/" <> _,
      },
      "optimized" => %{},
      "xhdpi" => %{},
      "hdpi" => %{},
      "mdpi" => %{},
      "ldpi" => %{},
    } = json[:one_by_two_image]

    assert %{
      "original" => %{},
      "optimized" => %{},
      "xhdpi" => %{},
      "hdpi" => %{},
      "mdpi" => %{},
      "ldpi" => %{},
    } = json[:two_by_one_image]

    assert %{
      "original" => %{},
      "optimized" => %{},
      "xhdpi" => %{},
      "hdpi" => %{},
      "mdpi" => %{},
      "ldpi" => %{},
    } = json[:two_by_two_image]
  end
end
