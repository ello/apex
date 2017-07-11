defmodule Ello.Serve.Webapp.UserControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    user = Factory.insert(:user, %{
      username: "archer",
      rendered_links: [
        %{"url"=>"http://www.twitter.com/ArcherFX",
          "text"=>"twitter.com/ArcherFX",
          "type"=>"Twitter",
          "icon"=>"https://social-icons.ello.co/twitter.png"},
      ],
    })
    {:ok, conn: conn, user: user}
  end

  test "it renders 404 if user does not exist", %{conn: conn} do
    resp = get(conn, "/nopenopenope")
    assert resp.status == 404
  end

  test "it renders 404 if private user and no known logged in user", %{conn: conn} do
    Factory.insert(:user, %{username: "private", is_public: false})
    resp = get(conn, "/private")
    assert resp.status == 404
  end

  test "it renders 200 if private user and known logged in user", %{conn: conn} do
    Factory.insert(:user, %{username: "private", is_public: false})
    resp = conn
           |> put_req_cookie("ello_skip_prerender", "true")
           |> get("/private")
    assert resp.status == 200
  end

  @tag :meta
  test "it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/archer")
    html = html_response(resp, 200)
    assert html =~ "<title>@archer | Ello</title>"
    assert has_meta(html, name: "name", content: "@archer | Ello")
    assert has_meta(html, name: "url", content: "https://ello.co/archer")
    assert has_meta(html, name: "description", content: "See @archer.*s work on Ello")

    assert has_meta(html, property: "og:url", content: "https://ello.co/archer")
    assert has_meta(html, property: "og:title", content: "@archer | Ello")
    assert has_meta(html, property: "og:description", content: "See @archer.*s work on Ello")

    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  test "it renders noscript with post summaries", %{conn: conn, user: user} do

    source_post = Factory.insert(:post)

    Factory.add_assets(Factory.insert(:post, author: user))
    Factory.insert(:post, author: user)
    Factory.add_assets(Factory.insert(:post, author: user))
    Factory.insert(:post, author: user, reposted_source: source_post)

    resp = get(conn, "/archer", %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "<h2>@archer</h2>"
    assert html =~ ~r"<h5>.*@archer.*</h5>"s
    assert html =~ ~r"<h6>.*@archer.*</h6>"s
  end
end
