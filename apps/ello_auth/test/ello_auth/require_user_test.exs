defmodule Ello.Auth.RequireUserTest do
  use Ello.Auth.Case
  alias Ello.Auth.{RequireUser, JWT}

  defmodule Example do
    use Plug.Builder
    plug RequireUser
    plug :foo
    def foo(conn, _), do: send_resp(conn, 200, "bar")
  end

  test "with a valid public token" do
    conn = conn("GET", "/doesnotmatter")
           |> put_req_header("authorization", "Bearer " <> JWT.generate)
    results = Example.call(conn, [])
    assert results.status == 401
  end

  test "with a valid user token" do
    user = Factory.insert(:user)
    conn = conn("GET", "/doesnotmatter")
           |> put_req_header("authorization", "Bearer " <> JWT.generate(user))
    results = Example.call(conn, [])
    assert results.status == 200
  end
end
