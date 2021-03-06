defmodule Ello.Serve.Webapp.LoveControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user = Factory.insert(:user, username: "archer")
    {:ok, conn: conn, user: user}
  end

  @tag :meta
  test "/:username/loves - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer/loves")
    html = html_response(resp, 200)
    assert html =~ "<title>Posts loved by @archer | Ello</title>"
    assert has_meta(html, name: "name", content: "Loves | @archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer/loves")
    assert has_meta(html, name: "description", content: "Posts loved by @archer | Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer/loves")
    assert has_meta(html, property: "og:title", content: "Posts loved by @archer | Ello")
    assert has_meta(html, property: "og:description", content: "Posts loved by @archer | Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  test "/:username/loves - it renders noscript with post summaries", %{conn: conn, user: user} do
    source_post = Factory.insert(:post)

    post1 = Factory.add_assets(Factory.insert(:post, author: user))
    post2 = Factory.insert(:post, author: user, reposted_source: source_post)
    post3 = Factory.add_assets(Factory.insert(:post))
    post4 = Factory.add_assets(Factory.insert(:post))

    Factory.insert(:love, %{post: post1, user: user, created_at: DateTime.from_unix!(4_000_000)})
    Factory.insert(:love, %{post: post2, user: user, created_at: DateTime.from_unix!(3_000_000)})
    Factory.insert(:love, %{post: post3, user: user, created_at: DateTime.from_unix!(2_000_000)})
    Factory.insert(:love, %{post: post4, user: user, created_at: DateTime.from_unix!(1_000_000)})


    resp = get(conn, "/archer/loves", %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "<h2>@archer</h2>"
    assert html =~ ~r"<h5>[\S\s]*@#{post1.author.username}[\S\s]*</h5>"
    assert html =~ ~r"<h5>[\S\s]*@#{post2.author.username}[\S\s]*</h5>"

    assert [_, before] = Regex.run(~r'"https://ello.co/archer/loves\?before=(.*)">Next Page</a>', html)

    resp2 = get(conn, "/archer/loves", %{"per_page" => "2", "before" => before})
    html2 = html_response(resp2, 200)

    refute html2 == html
    assert html2 =~ "<noscript>"
    assert html2 =~ ~r"<h5>[\S\s]*@#{post3.author.username}[\S\s]*</h5>"
    assert html2 =~ ~r"<h5>[\S\s]*@#{post4.author.username}[\S\s]*</h5>"
  end
end
