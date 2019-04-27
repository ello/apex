defmodule TH.Dash.SecretsControllerTest do
  use TH.Dash.ConnCase, async: false
  use ExUnit.Case

  setup %{conn: conn} do
    user = Factory.insert(:user)

    {:ok, conn: auth_conn(conn, user)}
  end

  test "GET /cidash/secrets", %{conn: conn} do
    conn = get(conn, "/api/cidash/secrets")
    resp = json_response(conn, 200)
    assert resp["twitter"]
    assert resp["bitly"]
  end
end
