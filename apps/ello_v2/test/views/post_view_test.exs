defmodule Ello.V2.PostViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.PostView
  alias Ello.Core.Content.{Post,Love,Watch}

  setup %{conn: conn} do
    archer = Script.build(:archer)
    reposter = Factory.build(:user)
    asset = Factory.build(:asset, %{id: 1})
    post = Factory.build(:post, %{
      id: 1,
      author: archer,
      assets: [asset],
      reposted_source: nil,
      repost_from_current_user: nil,
      love_from_current_user: nil,
      watch_from_current_user: nil,
    })
    repost = Factory.build(:post, %{
      id: 2,
      author: reposter,
      reposted_source: post,
      assets: []
    })
    current_user = Factory.build(:user)
    {:ok, [
        conn: user_conn(conn, current_user),
        archer: archer,
        post: post,
        repost: repost,
        reposter: reposter,
    ]}
  end

  test "post.json - it renders the post", %{post: post, archer: user, conn: conn} do
    assert %{
      id: "#{post.id}",
      href: "/api/v2/posts/#{post.id}",
      token: post.token,
      summary: [%{"data" => "<p>Phrasing!</p>", "kind" => "text", "link_url" => nil}],
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
      watched: false,
      repost_content: nil,
      repost_id: nil,
      links: %{
        author: %{id: "#{user.id}",
          type: "users",
          href: "/api/v2/users/#{user.id}"},
        assets: ["#{hd(post.assets).id}"]
      },
    } == render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "post.json - it renders the post repost_content", %{post: post, conn: conn} do
    repost_id = "123"
    repost = %{
      id: repost_id,
      rendered_content: [%{
        "kind" => "text",
        "data" => "<p>Phrasing!</p>",
        "link_url" => nil
      }],
    }
    post = Map.merge(post, %{
      reposted_source: repost
    })
    assert %{
      repost_id: ^repost_id,
      repost_content: [%{"kind" => "text", "data" => "<p>Phrasing!</p>"}],
    } = render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "post.json - it renders the post reposted loved watched", %{post: post, conn: conn} do
    post = Map.merge(post, %{
      repost_from_current_user: %Post{},
      love_from_current_user: %Love{deleted: false},
      watch_from_current_user: %Watch{},
    })
    assert %{
      reposted: true,
      loved: true,
      watched: true,
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

  test "post.json - it displays the content_warning for NSFW, 3rd Party Ads", %{post: post, conn: conn} do
    post = Map.merge(post, %{
      content_warning: "NSFW. May contain 3rd party ads.",
    })
    assert %{
      content_warning: "NSFW. May contain 3rd party ads.",
    } = render(PostView, "post.json",
      post: post,
      conn: conn
    )
  end

  test "show.json - it renders a post", %{post: post, archer: user, conn: conn} do
    user_id = "#{user.id}"
    post_id = "#{post.id}"
    asset_id = "#{hd(post.assets).id}"
    assert %{
      posts: %{
        id: ^post_id,
      },
      linked: %{
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
end
