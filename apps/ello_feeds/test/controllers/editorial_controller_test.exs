defmodule Ello.Feeds.EditorialControllerTest do
  use Ello.Feeds.ConnCase

  setup %{conn: conn} do
    Factory.insert(:post_editorial, published_position: 1)
    Factory.insert(:external_editorial, published_position: 2)
    Factory.insert(:category_editorial, published_position: 3)
    Factory.insert(:curated_posts_editorial, published_position: 4)
    Factory.insert(:internal_editorial, published_position: 5)
    Factory.insert(:following_editorial, published_position: 6)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    {:ok, conn: conn}
  end

  test "GET /feeds/editorials - as rss", %{conn: conn} do
    assert %{status: 200, resp_body: body} = get(conn, "/feeds/editorials")
    assert body =~ ~r(<title>Ello Editorials</title>)
    assert body =~ ~r(<title>Post Editorial</title>)
    assert body =~ ~r(<title>Internal Editorial</title>)
    assert body =~ ~r(<title>External Editorial</title>)
  end
end
