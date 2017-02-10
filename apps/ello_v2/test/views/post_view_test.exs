defmodule Ello.V2.PostViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.PostView

  setup %{conn: conn} do
    archer       = Script.build(:archer)
    post         = Factory.build(:post, %{
      id: 1,
      author: archer,
      repost_from_current_user: nil,
    })
    current_user = Factory.build(:user)
    {:ok, [
        conn: user_conn(conn, current_user),
        archer: archer,
        post: post,
    ]}
  end

  test "post.json - it renders the post", context do
    post = context.post
    user = context.archer
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
      links: %{
        author: %{id: "#{user.id}",
          type: "users",
          href: "/api/v2/users/#{user.id}"}
      }
    } == render(PostView, "post.json",
               post: context.post,
               conn: context.conn
             )
  end

  test "show.json - it renders post show", context do
    user_id = "#{context.archer.id}"
    post_id = "#{context.post.id}"
    assert %{
      posts: %{
        id: ^post_id,
      },
      linked: %{
        users: [%{id: ^user_id}],
      }
    } = render(PostView, "show.json",
      post: context.post,
      conn: context.conn
    )
  end
end
