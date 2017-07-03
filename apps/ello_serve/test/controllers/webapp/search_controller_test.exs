defmodule Ello.Serve.Webapp.SearchControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Search.Post.Index, as: PostIndex
  alias Ello.Search.User.Index, as: UserIndex

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    {:ok, conn: conn}
  end

  @tag :meta
  test "/search - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/search", %{terms: "ello"})
    html = html_response(resp, 200)
    assert html =~ "Search | Ello"
    assert has_meta(html, name: "description", content: "Find work .*")
  end

  @tag :meta
  test "/search?type=users - it renders the proper meta", %{conn: conn} do
    resp = get(conn, "/search", %{"terms" => "ello", "type" => "users"})
    html = html_response(resp, 200)
    assert html =~ "Search | Ello"
    assert has_meta(html, name: "description", content: "Find creators.*")
  end

  test "/search - it renders noscript", %{conn: conn} do
    post1 = Factory.insert(:post)
    post2 = Factory.insert(:post)
    post3 = Factory.insert(:post)

    PostIndex.delete
    PostIndex.create
    PostIndex.add(post1)
    PostIndex.add(post2)
    PostIndex.add(post3)

    resp = get(conn, "/search", %{terms: "Phrasing", per_page: "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "@#{post3.author.username()}"
    assert html =~ "@#{post2.author.username()}"

    resp = get(conn, "/search", %{terms: "Phrasing", page: "2", per_page: "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "@#{post1.author.username()}"
  end

  test "/search?type=users - it renders noscript", %{conn: conn} do
    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
    user3 = Factory.insert(:user)

    UserIndex.delete
    UserIndex.create
    UserIndex.add(user1)
    UserIndex.add(user2)
    UserIndex.add(user3)

    resp = get(conn, "/search", %{type: "users", terms: "username", per_page: "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "@username"

    resp = get(conn, "/search", %{type: "users", terms: "username", page: "2", per_page: "2"})
    html = html_response(resp, 200)

    assert html =~ "<noscript>"
    assert html =~ "@username"
  end
end
