defmodule Ello.Serve.Webapp.DiscoverPostControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Stream
  alias Ello.Search.Post.Index

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    Stream.Client.Test.start
    Stream.Client.Test.reset

    c1 = Factory.insert(:category, slug: "cat1", level: "primary", roshi_slug: "cat-1")
    c2 = Factory.insert(:category, slug: "cat2", level: "primary", roshi_slug: "cat-2")

    p1 = Factory.insert(:post, token: "token-p1", category_ids: [c1.id])
    p2 = Factory.insert(:post, token: "token-p2", category_ids: [c1.id])
    p3 = Factory.insert(:post, token: "token-p3", category_ids: [c1.id])
    p4 = Factory.insert(:post, token: "token-p4", category_ids: [c1.id])

    Index.delete
    Index.create
    Index.add(p1, post: %{love_count: 1000})
    Index.add(p2, post: %{love_count: 100})
    Index.add(p3, post: %{love_count: 10})
    Index.add(p4, post: %{love_count: 1})

    roshi_items = [
      %Stream.Item{id: "#{p1.id}", stream_id: "categories:v1:cat-1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p2.id}", stream_id: "categories:v1:cat-1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p3.id}", stream_id: "categories:v1:cat-1", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p4.id}", stream_id: "categories:v1:cat-1", ts: DateTime.utc_now},

      %Stream.Item{id: "#{p1.id}", stream_id: "all_post_firehose", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p2.id}", stream_id: "all_post_firehose", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p3.id}", stream_id: "all_post_firehose", ts: DateTime.utc_now},
      %Stream.Item{id: "#{p4.id}", stream_id: "all_post_firehose", ts: DateTime.utc_now},
    ]
    Stream.Client.add_items(roshi_items)

    {:ok, conn: conn}
  end

  @tag :meta
  test "/discover - meta", %{conn: conn} do
    resp = get(conn, "/discover")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Welcome .*")
  end

  test "/discover - noscript", %{conn: conn} do
    resp = get(conn, "/discover", %{"per_page" => "2"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ "token-p3"
    assert html =~ "token-p4"
    assert html =~ ~r(<a href="https://ello\.co/discover\?before=.*">Next Page</a>)
  end

  @tag :meta
  test "/discover/trending - meta", %{conn: conn} do
    resp = get(conn, "/discover/trending")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Explore trending .*")
  end

  test "/discover/trending - noscript", %{conn: conn} do
    resp = get(conn, "/discover/trending", %{"per_page" => "2"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ ~r(<a href="https://ello\.co/discover/trending\?before=2">Next Page</a>)
  end

  @tag :meta
  test "/discover/recent - meta", %{conn: conn} do
    resp = get(conn, "/discover/recent")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert has_meta(html, name: "description", content: "Discover recent .*")
  end

  test "/discover/recent - noscript", %{conn: conn} do
    resp = get(conn, "/discover/recent", %{"per_page" => "2"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ "token-p3"
    assert html =~ "token-p4"
    assert html =~ ~r(<a href="https://ello\.co/discover/recent\?before=.*">Next Page</a>)
  end

  @tag :meta
  test "/discover/cat1 - meta", %{conn: conn} do
    resp = get(conn, "/discover/cat1")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end

  test "/discover/cat1 - noscript", %{conn: conn} do
    resp = get(conn, "/discover/cat1", %{"per_page" => "2"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ "token-p3"
    assert html =~ "token-p4"
    assert html =~ ~r(<a href="https://ello\.co/discover/cat1\?before=.*">Next Page</a>)
  end

  @tag :meta
  test "/discover/cat1/trending - meta", %{conn: conn} do
    resp = get(conn, "/discover/cat1/trending")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
  end

  test "/discover/cat1/trending - noscript", %{conn: conn} do
    resp = get(conn, "/discover/cat1/trending", %{"per_page" => "2"})
    html = html_response(resp, 200)
    assert html =~ "<noscript>"
    assert html =~ "token-p1"
    assert html =~ "token-p2"
    assert html =~ ~r(<a href="https://ello\.co/discover/cat1/trending\?before=2.*">Next Page</a>)
  end
end
