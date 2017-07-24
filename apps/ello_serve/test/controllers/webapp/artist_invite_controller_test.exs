defmodule Ello.Serve.Webapp.ArtistInviteControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    a_inv1 = Factory.insert(:artist_invite, %{created_at: DateTime.from_unix!(5_000_000)})
    a_inv2 = Factory.insert(:artist_invite, %{status: "closed", created_at: DateTime.from_unix!(4_000_000)})
    Factory.insert(:artist_invite, %{title: "Not For Print1", created_at: DateTime.from_unix!(3_000_000)})
    Factory.insert(:artist_invite, %{title: "Not For Print2", created_at: DateTime.from_unix!(2_000_000)})
    Factory.insert(:artist_invite, %{title: "Asdf", created_at: DateTime.from_unix!(1_000_000)})
    sub1 = Factory.insert(:artist_invite_submission, %{artist_invite: a_inv1, status: "selected", created_at: DateTime.from_unix!(3_000_000)})
    sub2 = Factory.insert(:artist_invite_submission, %{artist_invite: a_inv1, status: "approved", created_at: DateTime.from_unix!(2_000_000)})
    sub3 = Factory.insert(:artist_invite_submission, %{artist_invite: a_inv1, status: "approved", created_at: DateTime.from_unix!(1_000_000)})
    {:ok,
      a_inv1: a_inv1,
      a_inv2: a_inv2,
      sub1: sub1,
      sub2: sub2,
      sub3: sub3,
      conn: conn}
  end

  @tag :meta
  test "artist-invites - meta", %{conn: conn} do
    resp = get(conn, "/artist-invites")
    html = html_response(resp, 200)
    assert html =~ "<title>Artist Invites | Ello</title>"
    assert has_meta(html, property: "og:title", content: "Artist Invites | Ello")
    assert has_meta(html, property: "og:description", content: "Artist Invites on Ello")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  test "artist-invites - it renders noscript", %{conn: conn} do
    resp = get(conn, "/artist-invites", %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "<h2>Foo Brand</h2>"
    assert html =~ ~r"<p>Bar</p>"
    assert [_, page] = Regex.run(~r'"https://ello.co/artist-invites\?page=(.*)">Next Page</a>', html)

    resp2 = get(conn, "/artist-invites", %{"per_page" => "2", "page" => page})
    html2 = html_response(resp2, 200)

    refute html2 == html
    assert page == "2"
    assert html2 =~ "<noscript>"
    assert html2 =~ "<h2>Not For Print1</h2>"

    resp3 = get(conn, "/artist-invites", %{"per_page" => "2", "page" => "3"})
    html3 = html_response(resp3, 200)

    refute html3 == html2
    assert html3 =~ "<noscript>"
    assert html3 =~ "<h2>Asdf</h2>"
  end

  @tag :meta
  test "artist-invites/:id - meta", %{conn: conn, a_inv1: a_inv1} do
    resp = get(conn, artist_invite_path(conn, :show, a_inv1))
    html = html_response(resp, 200)

    assert html =~ "<title>Foo Brand | Ello</title>"
    assert has_meta(html, property: "og:title", content: "Foo Brand | Ello")
    assert has_meta(html, property: "og:description", content: "Bar")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  @tag :meta
  test "artist-invites/:slug - meta", %{conn: conn, a_inv1: a_inv1} do
    resp = get(conn, artist_invite_path(conn, :show, "~#{a_inv1.slug}"))
    html = html_response(resp, 200)

    assert html =~ "<title>Foo Brand | Ello</title>"
    assert has_meta(html, property: "og:title", content: "Foo Brand | Ello")
    assert has_meta(html, property: "og:description", content: "Bar")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  test "artist-invites/:id - it renders noscript", %{conn: conn, a_inv1: a_inv1, sub1: sub1, sub2: sub2, sub3: sub3} do
    resp = get(conn, artist_invite_path(conn, :show, a_inv1), %{"per_page" => "2"})
    html = html_response(resp, 200)

    assert html =~ "<title>Foo Brand | Ello</title>"
    assert html =~ "<h1>#{a_inv1.title}</h1>"
    assert html =~ "<h3>#{a_inv1.invite_type}</h3>"
    assert html =~ "<h2>#{a_inv1.status}</h2>"
    assert html =~ "<p>#{a_inv1.raw_description}</p>"
    assert html =~ "<h3>#{hd(a_inv1.guide)[:title]}</h3>"
    assert html =~ "<p>#{hd(a_inv1.guide)[:raw_body]}</p>"
    assert html =~ "<h2>Submissions</h2>"
    refute html =~ "<h2>Selections</h2>"
    assert html =~ sub1.post.token
    assert html =~ sub2.post.token
    refute html =~ sub3.post.token
    assert [_, before] = Regex.run(~r'before=(.*)">Next Page</a>', html)

    resp2 = get(conn, artist_invite_path(conn, :show, a_inv1), %{"per_page" => "2", "before" => before})
    html2 = html_response(resp2, 200)

    refute html2 == html
    assert html2 =~ sub3.post.token
  end

  test "artist-invites/:id - it renders noscript with selections", %{conn: conn, a_inv2: a_inv2} do
    resp = get(conn, artist_invite_path(conn, :show, a_inv2, %{"per_page" => "2"}))
    html = html_response(resp, 200)
    assert html =~ "<h2>Selections</h2>"
  end
end
