defmodule Ello.Serve.Webapp.EditorialControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Stream
  alias Ello.Search.Post.Index

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    Factory.insert(:post_editorial, published_position: 1)
    Factory.insert(:post_editorial, published_position: 2)
    Factory.insert(:post_editorial, published_position: 3)
    Factory.insert(:post_editorial, published_position: 4)
    Factory.insert(:artist_invite_editorial, published_position: 5)
    Factory.insert(:external_editorial, published_position: 6)
    Factory.insert(:internal_editorial, published_position: 7)
    Factory.insert(:category_editorial, published_position: 8)
    Factory.insert(:curated_posts_editorial, published_position: 9)
    Factory.insert(:following_editorial, published_position: 10)
    Factory.insert(:invite_join_editorial, published_position: 11)

    cat1 = Factory.insert(:category, slug: "shop", level: "primary")

    p1 = Factory.add_assets(Factory.insert(:post, token: "token-p1"))
    p2 = Factory.add_assets(Factory.insert(:post, token: "token-p2"))
    p3 = Factory.add_assets(Factory.insert(:post, token: "token-p3"))
    p4 = Factory.add_assets(Factory.insert(:post, token: "token-p4"))
    Factory.insert(:category_post, category: cat1, post: p1)
    Factory.insert(:category_post, category: cat1, post: p2)
    Factory.insert(:category_post, category: cat1, post: p3)
    Factory.insert(:category_post, category: cat1, post: p4)

    Index.delete
    Index.create
    Index.add(p1, post: %{love_count: 1000})
    Index.add(p2, post: %{love_count: 100})
    Index.add(p3, post: %{love_count: 10})
    Index.add(p4, post: %{love_count: 1})

    invite = Factory.insert(:artist_invite, slug: "nfp-100", status: "open")
    Factory.insert(:artist_invite_submission, post: p1, artist_invite: invite, status: "approved")
    Factory.insert(:artist_invite_submission, post: p2, artist_invite: invite, status: "approved")
    Factory.insert(:artist_invite_submission, post: p3, artist_invite: invite, status: "approved")
    Factory.insert(:artist_invite_submission, post: p4, artist_invite: invite, status: "approved")

    roshi_items = [
      %Stream.Item{id: "#{p1.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p2.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p3.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p4.id}", stream_id: "categories:v1:cat1", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    {:ok, conn: conn}
  end

  @tag :meta
  test "editorial - meta", %{conn: conn} do
    resp = get(conn, "/", %{"per_page" => "7"})
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Welcome .*")
    assert html =~ ~r(<link rel="next" href="https://ello\.co\?before=5" />)s
    assert html =~ ~r(<link rel="alternate".*href="https://ello\.co/feeds/editorials".*/>)s
  end

  test "editorial - noscript", %{conn: conn} do
    resp = get(conn, "/", %{"per_page" => "8"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"

    assert html =~ ~r(<a href="https://ello.co/join">Join Ello</a>)

    assert html =~ "Trending on Ello: @"
    assert html =~ ~r(<a href="https://ello\.co/.*/post/.*">.*Trending on Ello: @.*</a>)s

    assert html =~ "Curated Posts Editorial"
    assert html =~ ~r(<a href="https://ello\.co/.*/post/.*">.*Curated Posts Editorial.*</a>)s

    assert html =~ "Category Editorial @"
    assert html =~ ~r(<a href="https://ello\.co/.*/post/.*">.*Category Editorial @.*</a>)s

    assert html =~ "Internal Editorial"
    assert html =~ ~r(<a href="https://ello\.co/discover/recent">)

    assert html =~ "External Editorial"
    assert html =~ ~r(<a href="https://ello\.co/wtf">)

    assert html =~ "Artist Invite Editorial"
    assert html =~ ~r(<a href="https://ello\.co/.*/post/.*">.*Artist Invite Editorial @.*</a>)s

    assert html =~ "Post Editorial"
    assert html =~ ~r(<a href="https://ello\.co/.*/post/.*">)

    assert html =~ ~r(<a href="https://ello\.co\?before=4">Next Page</a>)s
  end
end
