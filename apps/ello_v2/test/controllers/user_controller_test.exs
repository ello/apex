defmodule Ello.V2.UserControllerTest do
  use Ello.V2.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user)
    spying = Script.insert(:espionage_category)
    archer = Script.insert(:archer, category_ids: [spying.id])
    {:ok, conn: auth_conn(conn, user), unauth_conn: conn, archer: archer}
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
end
