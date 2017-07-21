defmodule Ello.Serve.Webapp.ArtistInviteControllerTest do
  use Ello.Serve.ConnCase

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Factory.insert(:artist_invite)
    {:ok, conn: conn}
  end

  # TODO: Test pagination
  @tag :meta
  test "artist_invites - meta", %{conn: conn} do
    resp = get(conn, "/artist_invites")
    html = html_response(resp, 200)
    assert html =~ "<title>Artist Invites | Ello</title>"
    assert has_meta(html, property: "og:title", content: "Artist Invites | Ello")
    assert has_meta(html, property: "og:description", content: "Artist Invites on Ello")
    assert has_meta(html, name: "robots", content: "index, follow")
  end

  test "artist_invites - it renders noscript", %{conn: conn} do
    resp = get(conn, "/artist_invites")
    html = html_response(resp, 200)
    html |> IO.puts

    assert html =~ "<noscript>"
    assert html =~ "<h2>Foo Brand</h2>"
    assert html =~ ~r"<p>Bar</p>"s
    # assert html =~ ~r"<h6>.*@archer.*</h6>"s
  end
end
