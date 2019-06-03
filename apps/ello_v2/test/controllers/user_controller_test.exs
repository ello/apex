defmodule Ello.V2.UserControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.{Redis, Repo}
  alias Ello.Search.User.Index

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    user = Factory.insert(:user)
    spying = Script.insert(:espionage_category)
    archer = Script.insert(:archer)
    Factory.insert(:category_user, user: archer, category: spying)
    {:ok, conn: auth_conn(conn, user), unauth_conn: conn, archer: archer, user: user}
  end

  test "GET /v2/users/:id - without token", %{unauth_conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert conn.status == 401
  end

  test "GET /v2/users/:id - public token", %{unauth_conn: conn, archer: archer} do
    conn = conn
           |> public_conn
           |> get(user_path(conn, :show, archer))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/:id - user token", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/~:username - user token", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, "~#{archer.username}"))
    assert %{"name" => "Sterling Archer"} = json_response(conn, 200)["users"]
  end

  test "GET /v2/users/:id - 304", %{conn: conn, archer: archer} do
    resp = get(conn, user_path(conn, :show, archer))
    assert resp.status == 200
    [etag] = get_resp_header(resp, "etag")
    resp2 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_path(conn, :show, archer))
    assert resp2.status == 304
    archer
    |> Ecto.Changeset.change(%{updated_at: FactoryTime.now_offset(1)})
    |> Ello.Core.Repo.update!
    resp3 = conn
            |> put_req_header("if-none-match", etag)
            |> get(user_path(conn, :show, archer))
    assert resp3.status == 200
  end

  @tag :json_schema
  test "GET /v2/users/:id - json schema", %{conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :show, archer))
    assert :ok = validate_json("user", json_response(conn, 200))
  end

  test "GET /v2/users/:id - when blocked", context do
    Redis.command(["SADD", "user:#{context.user.id}:block_id_cache", context.archer.id])

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404

    Redis.command(["SREM", "user:#{context.user.id}:block_id_cache", context.archer.id])
  end

  test "GET /v2/users/:id - when inverse blocked", context do
    Redis.command(["SADD", "user:#{context.user.id}:inverse_block_id_cache", context.archer.id])

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404

    Redis.command(["SREM", "user:#{context.user.id}:inverse_block_id_cache", context.archer.id])
  end

  test "GET /v2/users/:id - when locked", context do
    context.archer
    |> Ecto.Changeset.change(locked_at: FactoryTime.now)
    |> Ello.Core.Repo.update!

    conn = auth_conn(context.unauth_conn, context.user)
    conn = get(conn, user_path(conn, :show, context.archer))
    assert conn.status == 404
  end

  test "GET /v2/users/:id - public token, private user ", %{unauth_conn: conn, archer: archer} do
    archer
    |> Ecto.Changeset.change(is_public: false)
    |> Ello.Core.Repo.update!

    conn = conn
           |> public_conn
           |> get(user_path(conn, :show, archer))

    assert conn.status == 404
  end

  test "GET /v2/users/autocomplete - without token", %{unauth_conn: conn, archer: archer} do
    conn = get(conn, user_path(conn, :autocomplete, %{"terms" => archer.username}))
    assert conn.status == 401
  end

  test "GET /v2/users/autocomplete - public token", %{unauth_conn: conn, archer: archer} do
    conn = conn
           |> public_conn
           |> get(user_path(conn, :autocomplete, %{"terms" => archer.username}))
    assert conn.status == 401
  end

  test "GET /v2/users/autocomplete - user token", %{conn: conn, archer: archer} do
    Index.delete
    Index.create
    Index.add(archer)
    conn = get(conn, user_path(conn, :autocomplete, %{"terms" => archer.username}))
    assert %{"autocomplete_results" => [%{"image_url" => "https://assets.ello.co/uploads/user/avatar/42/ello-small-fad52e18.png",
              "name" => "archer"}]} = json_response(conn, 200)
  end

  test "GET /v2/users/autocomplete - user token with no search results", %{conn: conn} do
    conn = get(conn, user_path(conn, :autocomplete, %{"terms" => "asdf"}))
    assert conn.status == 204
  end

  test "GET /v2/users - without token", %{unauth_conn: conn} do
    conn = get(conn, user_path(conn, :index, %{"terms" => "archer"}))
    assert conn.status == 401
  end

  test "GET /v2/users - public token", %{unauth_conn: conn, archer: archer} do
    Index.delete
    Index.create
    Index.add(archer)
    conn = conn
           |> public_conn
           |> get(user_path(conn, :index, %{"terms" => "archer"}))
    assert %{"name" => "Sterling Archer"} = hd(json_response(conn, 200)["users"])
  end

  test "GET /v2/users - user token", %{conn: conn, archer: archer} do
    Index.delete
    Index.create
    Index.add(archer)
    conn = get(conn, user_path(conn, :index, %{"terms" => "archer"}))
    assert [link] = get_resp_header(conn, "link")
    assert String.contains?(link, "terms=archer")
    assert String.contains?(link, "page=2")
    assert String.contains?(link, "/api/v2/users")
    assert %{"name" => "Sterling Archer"} = hd(json_response(conn, 200)["users"])
  end
end
