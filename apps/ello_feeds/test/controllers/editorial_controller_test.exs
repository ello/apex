defmodule Ello.Feeds.EditorialControllerTest do
  use Ello.Feeds.ConnCase
  import SweetXml

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
    assert xpath(body, ~x"/rss/channel/title/text()"s) == "Ello Editorials"
    assert xpath(body, ~x"/rss/channel/description/text()"s)
    assert xpath(body, ~x"/rss/channel/link/text()"s)
    assert xpath(body, ~x"/rss/channel/image/link/text()"s) == "https://ello.co"
    assert xpath(body, ~x"/rss/channel/item[1]/title/text()"s) == "Internal Editorial"
    assert xpath(body, ~x"/rss/channel/item[1]/description/text()"s)
    assert xpath(body, ~x"/rss/channel/item[1]/link/text()"s) == "https://ello.co/discover/recent"

    assert xpath(body, ~x"/rss/channel/item[2]/title/text()"s) == "External Editorial"
    assert xpath(body, ~x"/rss/channel/item[2]/description/text()"s)
    assert xpath(body, ~x"/rss/channel/item[2]/link/text()"s) =~ "https://ello.co/wtf"

    assert xpath(body, ~x"/rss/channel/item[3]/title/text()"s) == "Post Editorial"
    assert xpath(body, ~x"/rss/channel/item[3]/description/text()"s)
    assert xpath(body, ~x"/rss/channel/item[3]/link/text()"s) =~ ~r"https://ello.co/.*/post/.*"
  end
end
