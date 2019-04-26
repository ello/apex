defmodule TH.Dash.CredsControllerTest do
  use TH.Dash.ConnCase, async: false
  use ExUnit.Case

  setup %{conn: conn} do
    user = Factory.insert(:user)

    {:ok, conn: auth_conn(conn, user)}
  end

  test "GET /cidash/creds", %{conn: conn} do
    conn = get(conn, "/api/cidash/creds")
    resp = json_response(conn, 200)
    assert resp["twitter"]
    assert resp["bitly"]
  end
end
