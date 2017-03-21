defmodule Ello.Auth.RequireUserTest do
  use Ello.Auth.Case
  alias Ello.Auth.{RequireUser, RequireToken, JWT}

  defmodule Example do
    use Plug.Builder
    plug RequireToken
    plug RequireUser
    plug :foo
    def foo(conn, _), do: send_resp(conn, 200, "bar")
  end

  setup do
    {:ok, conn: conn("GET", "/doesnotmatter")}
  end

  test "with a valid public token", %{conn: conn} do
    resp = conn
           |> put_req_header("authorization", "Bearer " <> JWT.generate)
           |> Example.call([])
    assert resp.status == 401
  end

  test "with a valid user token", %{conn: conn} do
    user = NetworkStub.user(1)
    resp = conn
           |> put_req_header("authorization", "Bearer " <> JWT.generate(user))
           |> Example.call([])
    assert resp.status == 200
    assert resp.assigns.current_user == user
  end

  test "when user can not be found", %{conn: conn} do
    user = %{id: 404}
    resp = conn
           |> put_req_header("authorization", "Bearer " <> JWT.generate(user))
           |> Example.call([])
    assert resp.status == 401
  end
end
