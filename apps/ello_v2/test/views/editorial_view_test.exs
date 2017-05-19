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

  test "editorial.json - following kind - authenticated", context do
    user = Factory.build(:user)
    conn = assign(context.conn, :current_user, user)
    editorial = Editorial.build_images(Factory.insert(:following_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "post_stream"
    refute json[:subtitle]
    refute json[:url]
    assert json[:links][:post_stream][:type] == "posts"
    assert json[:links][:post_stream][:href] == "/api/v2/following/posts/trending?stream_source=editorial&per_page=5"
  end

  test "editorial.json - following kind - anonymous", context do
    editorial = Editorial.build_images(Factory.insert(:following_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "post_stream"
    refute json[:subtitle]
    refute json[:url]
    assert json[:links][:post_stream][:type] == "posts"
    assert json[:links][:post_stream][:href] == "/api/v2/discover/posts/trending?stream_source=editorial&per_page=5"
  end

  test "editorial.json - invite_join kind - authenticated", context do
    user = Factory.build(:user)
    conn = assign(context.conn, :current_user, user)
    editorial = Editorial.build_images(Factory.insert(:invite_join_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "invite"
  end

  test "editorial.json - invite_join kind - anonymous", context do
    editorial = Editorial.build_images(Factory.insert(:invite_join_editorial))
    json = render(EditorialView, "editorial.json",
      editorial: editorial,
      conn: context.conn
    )
    assert json[:id] == "#{editorial.id}"
    assert json[:kind] == "join"
  end

  test "editorial.json - images", context do
    editorial = :post_editorial
                |> Factory.insert(%{one_by_two_image: nil, one_by_two_image_metadata: %{}})
                |> Editorial.build_images()

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
        url: "https://assets.ello.co/uploads/editorial/one_by_one_image/" <> _,
      },
      "optimized" => %{},
      "xhdpi" => %{},
      "hdpi" => %{},
      "mdpi" => %{},
      "ldpi" => %{},
    } = json[:one_by_two_image]

    assert %{
      "original" => %{
        url: "https://assets.ello.co/uploads/editorial/two_by_one_image/" <> _,
      },
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
