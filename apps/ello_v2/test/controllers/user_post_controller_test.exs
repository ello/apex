defmodule Ello.V2.UserPostControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.{Repo, Network}
  alias Network.User

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    author = Factory.insert(:user)
    nsfw_author = Factory.insert(:user, %{settings: %User.Settings{posts_adult_content: true}})
    now = DateTime.utc_now |> DateTime.to_unix
    posts = Enum.map 1..8, fn (i) ->
      Factory.insert(:post, %{
        author:     author,
        created_at: DateTime.from_unix!(now - (i * 1000))
      })
    end
    nsfw_posts = Enum.map 1..8, fn (i) ->
      Factory.insert(:post, %{
        author:           nsfw_author,
        is_adult_content: true,
        created_at:       DateTime.from_unix!(now - (i * 1000))
      })
    end
    post = hd(posts)
    {:ok, [
      conn: auth_conn(conn, user),
      public_conn: public_conn(conn),
      author_conn: auth_conn(conn, author),
      user: user,
      author: author,
      nsfw_author: nsfw_author,
      posts: posts,
      post: post
    ]}
  end

  test "GET /v2/users/:id/posts", %{conn: conn, author: author} do
    response = get(conn, user_post_path(conn, :index, author))
    assert response.status == 200
  end

  test "GET /v2/users/:id/posts - no posts when no current user and author is NSFW", %{public_conn: conn, nsfw_author: author} do
    response = get(conn, user_post_path(conn, :index, author))
    assert response.status == 204
  end

  test "GET /v2/users/:id/posts - no posts", %{conn: conn} do
    user = Factory.insert(:user)
    response = get(conn, user_post_path(conn, :index, user))
    assert response.status == 204
  end

  test "GET /v2/user/:id/posts - 304", %{conn: conn, author: author} do
    resp = get(conn, user_post_path(conn, :index, author))
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_post_path(conn, :index, author))
    assert resp2.status == 304
    Factory.insert(:post, author: author)
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_post_path(conn, :index, author))
    assert resp3.status == 200
  end

  test "GET /v2/users/:id/posts - returns page headers", %{conn: conn, author: author} do
    response = get(conn, user_post_path(conn, :index, author), %{per_page: "2"})
    refute get_resp_header(response, "x-last-page") == ["true"]
    refute get_resp_header(response, "x-total-pages-remaining") == ["0"]

    assert [link] = get_resp_header(response, "link")
    link_regex = ~r/(^|, *)<(.*?)>; rel="next"(,|$)/
    assert Regex.match?(link_regex, link)
  end

  test "GET /v2/users/:id/posts - returns correct page headers with before date", %{conn: conn, author: author} do
    {:ok, one_sec_ago} = DateTime.utc_now |> DateTime.to_unix |> Kernel.-(1) |> DateTime.from_unix
    %{
      year: year, month: month, day: day,
      hour: hour, minute: minute, second: second
    } = one_sec_ago

    year = String.pad_leading("#{year}", 2, "0")
    month = String.pad_leading("#{month}", 2, "0")
    day = String.pad_leading("#{day}", 2, "0")
    hour = String.pad_leading("#{hour}", 2, "0")
    minute = String.pad_leading("#{minute}", 2, "0")
    second = String.pad_leading("#{second}", 2, "0")

    before = "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}Z"
    response = get(conn, user_post_path(conn, :index, author), %{per_page: "2", before: before})
    assert ["<https://ello.co/api/v2/users/" <> _] = get_resp_header(response, "link")
    refute get_resp_header(response, "x-last-page") == ["true"]
    refute get_resp_header(response, "x-total-pages-remaining") == ["0"]
  end

  test "GET /v2/users/:id/posts - using link headers to fetch next page returns results", %{conn: conn, author: author} do
    response = get(conn, user_post_path(conn, :index, author), %{per_page: "7"})
    assert response.status == 200
    refute get_resp_header(response, "x-last-page") == ["true"]
    refute get_resp_header(response, "x-total-pages-remaining") == ["0"]
    assert [link] = get_resp_header(response, "link")

    [_, url | _] = Regex.run(~r/<(.*?)>; rel="next"/, link)
    [_, before | _] = Regex.run(~r/[?&]before=(.*?)(&|$)/, url)
    [_, per_page | _] = Regex.run(~r/[?&]per_page=(.*?)(&|$)/, url)

    response2 = get(conn, user_post_path(conn, :index, author), %{before: before, per_page: per_page})
    assert response2.status == 200
    assert get_resp_header(response2, "x-last-page") == ["true"]
    assert get_resp_header(response2, "x-total-pages-remaining") == ["0"]
    assert get_resp_header(response2, "link") == []
  end

  test "GET /v2/users/:id/posts 404s", %{conn: conn} do
    response = get(conn, user_post_path(conn, :index, "404"))
    assert response.status == 404
  end

  test "GET /v2/profile/posts - without current user", %{public_conn: conn} do
    response = get(conn, "/api/v2/profile/posts")
    assert response.status == 401
  end

  test "GET /v2/profile/posts - with current user", %{author_conn: conn} do
    response = get(conn, "/api/v2/profile/posts")
    json = json_response(response, 200)
    assert length(json["posts"]) == 8
  end
end
