defmodule TH.TrueDash.StatusControllerTest do
  use TH.TrueDash.ConnCase, async: false
  use ExUnit.Case

  setup %{conn: conn} do
    user = Factory.insert(:user)

    {:ok, conn: auth_conn(conn, user)}
  end

  test "GET /cidash/ping", %{conn: conn} do
    conn = get(conn, "/api/cidash/ping")
    assert conn.status == 200
  end
end
