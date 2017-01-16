defmodule Ello.Auth.RequireTokenTest do
  use Ello.Auth.Case
  alias Ello.Auth.{RequireToken, JWT}

  defmodule Example do
    use Plug.Builder
    plug RequireToken
    plug :foo
    def foo(conn, _), do: send_resp(conn, 200, "bar")
  end

  setup do
    {:ok, conn: conn("GET", "/doesnotmatter")}
  end

  test "without a token", %{conn: conn} do
    resp = Example.call(conn, [])
    assert resp.status == 401
  end

  test "with an invalid token", %{conn: conn} do
    resp = conn
           |> put_req_header("authorization", "Bearer ey.nonsense.foo")
           |> Example.call([])
    assert resp.status == 401
  end

  test "with a valid public token", %{conn: conn} do
    resp = conn
           |> put_req_header("authorization", "Bearer " <> JWT.generate)
           |> Example.call([])
    assert resp.status == 200
    refute resp.assigns[:current_user]
  end

  test "with a valid user token", %{conn: conn} do
    user = NetworkStub.user(1)
    resp = conn
           |> put_req_header("authorization", "Bearer " <> JWT.generate(user))
           |> Example.call([])
    assert resp.status == 200
    assert resp.assigns[:current_user] == user
  end
end
