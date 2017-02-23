defmodule Ello.V2.PostViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.PostView
  alias Ello.Core.Content.{Post,Love,Watch,Asset}

  setup %{conn: conn} do
    archer = Script.build(:archer)
    reposter = Factory.build(:user)
    category = Factory.build(:category, %{id: 3})
    asset = Asset.build_attachment(Factory.build(:asset, %{id: 1}))
    post = Factory.build(:post, %{
      id: 1,
      author: archer,
      assets: [asset],
      reposted_source: nil,
      repost_from_current_user: nil,
      love_from_current_user: nil,
      watch_from_current_user: nil,
      rendered_summary: [
        %{"data" => "<p>Post</p>", "kind" => "text", "link_url" => nil}
      ],
      categories: [category],
      category_ids: [category.id],
    })
    repost = Factory.build(:post, %{
      id: 2,
      author: reposter,
      reposted_source: post,
      comments_count: 0,
      loves_count: 0,
      reposts_count: 0,
      views_count: 0,
      assets: [],
      rendered_summary: [
        %{"data" => "<p>Repost</p>", "kind" => "text", "link_url" => nil}
      ],
    })
    current_user = Factory.build(:user)
    {:ok, [
        conn: user_conn(conn, current_user),
        archer: archer,
        category: category,
        post: post,
        repost: repost,
        reposter: reposter,
    ]}
  end

  test "post.json - it renders the post", %{category: category, post: post, archer: user, conn: conn} do
    assert %{
      id: "#{post.id}",
      href: "/api/v2/posts/#{post.id}",
      token: post.token,
      summary: [%{"data" => "<p>Post</p>", "kind" => "text", "link_url" => nil}],
      content: [%{"data" => "<p>Phrasing!</p>", "kind" => "text", "link_url" => nil}],
      author_id: "#{user.id}",
      is_adult_content: post.is_adult_content,
      body: [%{"data" => "Phrasing!", "kind" => "text"}],
      loves_count: 1,
      comments_count: 2,
      reposts_count: 3,
      views_count: 4_123,
      views_count_rounded: "4.12K",
      created_at: post.created_at,
      reposted: false,
      loved: false,
      watching: false,
      repost_content: [],
      repost_id: "",
      content_warning: "",
      links: %{
        categories: ["#{category.id}"],
        author: %{
          id: "#{user.id}",
          type: "users",
          href: "/api/v2/users/#{user.id}"
        },
        assets: ["#{hd(post.assets).id}"]
      },
    } == render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "post.json - it renders a repost", %{post: post, repost: repost, conn: conn} do
    post_id = "#{post.id}"
    assert %{
      repost_id: ^post_id,
      repost_content: [%{"kind" => "text", "data" => "<p>Phrasing!</p>"}],
      summary: [%{"kind" => "text", "data" => "<p>Post</p>"}],
      loves_count: 1,
      comments_count: 2,
      reposts_count: 3,
      views_count: 4_123,
    } = render(PostView, "post.json",
      post: repost,
      conn: conn
    )
  end

  test "post.json - it renders the post reposted loved watching", %{post: post, conn: conn} do
    post = Map.merge(post, %{
      repost_from_current_user: %Post{},
      love_from_current_user: %Love{deleted: false},
      watch_from_current_user: %Watch{},
    })
    assert %{
      reposted: true,
      loved: true,
      watching: true,
    } = render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "post.json - it renders the post not loved because love was deleted", %{post: post, conn: conn} do
    post = Map.merge(post, %{
      love_from_current_user: %Love{deleted: true},
    })
    assert %{
      loved: false,
    } = render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "post.json - it displays the content_warning for 3rd party ads", %{conn: conn} do
    settings = Factory.build(:settings, %{has_ad_notifications_enabled: true})
    current_user = Factory.build(:user, %{settings: settings})
    post = Factory.build(:post, %{
      assets: [],
      reposted_source: nil,
      body: [
        %{"kind" => "embed"}
      ],
    })

    assert %{content_warning: "May contain 3rd party ads."} = render(PostView, "post.json",
      post: post,
      conn: assign(conn, :current_user, current_user)
    )
  end

  test "show.json - it renders a post", %{category: category, post: post, archer: user, conn: conn} do
    user_id = "#{user.id}"
    category_id = "#{category.id}"
    post_id = "#{post.id}"
    post_token = post.token
    asset_id = "#{hd(post.assets).id}"
    assert %{
      posts: %{
        id: ^post_id,
        meta_attributes: %{
          description: "Phrasing!",
          images: ["https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg"],
          embeds: nil,
          robots: "index, follow",
          title: "test post",
          url: "https://ello.co/archer/post/" <> ^post_token,
          canonical_url: nil,
        },
      },
      linked: %{
        categories: [%{id: ^category_id}],
        users: [%{id: ^user_id}],
        assets: [%{id: ^asset_id}],
      }
    } = render(PostView, "show.json",
      post: post,
      conn: conn
    )
  end

  test "show.json - it renders a linked repost", %{post: post, archer: archer, repost: repost, reposter: reposter, conn: conn} do
    author_id = "#{archer.id}"
    repost_author_id = "#{reposter.id}"
    repost_id = "#{repost.id}"
    post_id = "#{post.id}"
    asset_id = "#{hd(post.assets).id}"
    assert %{
      posts: %{
        id: ^repost_id,
      },
      linked: %{
        users: users,
        posts: [%{id: ^post_id}],
        assets: [%{id: ^asset_id}],
      }
    } = render(PostView, "show.json",
      post: repost,
      conn: conn
    )
    assert Enum.any?(users, &(&1.id == author_id))
    assert Enum.any?(users, &(&1.id == repost_author_id))
  end

  test "index.json - it renders a list of posts", %{archer: archer, conn: conn} do
    user_id = "#{archer.id}"
    id1 = "1"
    id2 = "2"
    posts = [
      Factory.build(:post, %{id: id1, author: archer, assets: [], reposted_source: nil}),
      Factory.build(:post, %{id: id2, author: archer, assets: [], reposted_source: nil}),
    ]
    assert %{
      posts: [
        %{id: ^id1, author_id: ^user_id},
        %{id: ^id2, author_id: ^user_id},
      ],
      linked: %{
        users: [%{id: ^user_id}],
      }
    } = render(PostView, "index.json",
      posts: posts,
      conn: conn
    )
  end

  test "index.json - it renders a list of posts with linked reposts and assets", %{archer: archer, reposter: reposter, conn: conn} do
    user_id1 = "#{archer.id}"
    user_id2 = "#{reposter.id}"

    post_id1 = "1"
    asset_id1 = "11"
    post_id2 = "2"
    asset_id2 = "22"
    reposted_source_id = "3"
    asset_id3 = "33"

    post1 = Factory.build(:post, %{
      id: post_id1,
      author: archer,
      assets: [Asset.build_attachment(Factory.build(:asset, %{id: asset_id1}))],
      reposted_source: nil,
    })
    post2 = Factory.build(:post, %{
      id: post_id2,
      author: archer,
      assets: [Asset.build_attachment(Factory.build(:asset, %{id: asset_id2}))],
      reposted_source: Factory.build(:post, %{
        id: reposted_source_id,
        author: reposter,
        assets: [Asset.build_attachment(Factory.build(:asset, %{id: asset_id3}))],
        reposted_source: nil,
      }),
    })

    posts = [
      post1,
      post2,
    ]
    assert %{
      posts: [
        %{id: ^post_id1, author_id: ^user_id1},
        %{id: ^post_id2, author_id: ^user_id1},
      ],
      linked: %{
        users: users,
        posts: [%{id: ^reposted_source_id}],
        assets: assets,
      }
    } = render(PostView, "index.json",
      posts: posts,
      conn: conn
    )

    assert length(users) == 2
    assert Enum.any?(users, &(&1.id == user_id1))
    assert Enum.any?(users, &(&1.id == user_id2))

    assert length(assets) == 3
    assert Enum.any?(assets, &(&1.id == asset_id1))
    assert Enum.any?(assets, &(&1.id == asset_id2))
    assert Enum.any?(assets, &(&1.id == asset_id3))
  end
end
