defmodule Ello.V2.UserControllerTest do
  use Ello.V2.ConnCase, async: false
  alias Ello.Core.Redis

  setup %{conn: conn} do
    user = Factory.insert(:user)
    spying = Script.insert(:espionage_category)
    archer = Script.insert(:archer, category_ids: [spying.id])
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
    |> Ecto.Changeset.change(locked_at: Ecto.DateTime.utc)
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
end
