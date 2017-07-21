defmodule Ello.Serve.Webapp.ArtistInviteControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Factory.insert(:artist_invite, %{created_at: DateTime.from_unix!(5_000_000)})
    Factory.insert(:artist_invite, %{created_at: DateTime.from_unix!(4_000_000)})
    Factory.insert(:artist_invite, %{title: "Not For Print1", created_at: DateTime.from_unix!(3_000_000)})
    Factory.insert(:artist_invite, %{title: "Not For Print2", created_at: DateTime.from_unix!(2_000_000)})
    Factory.insert(:artist_invite, %{title: "Asdf", created_at: DateTime.from_unix!(1_000_000)})
    {:ok, conn: conn}
  end

  # TODO: Test pagination
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
end
