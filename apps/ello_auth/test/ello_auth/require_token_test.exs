defmodule Ello.Auth.RequireTokenTest do
  use Ello.Auth.Case
  alias Ello.Auth.{RequireToken, JWT}

  defmodule Example do
    use Plug.Builder
    plug RequireToken
    plug :foo
    def foo(conn, _), do: send_resp(conn, 200, "bar")
  end

  test "without a token" do
    conn = conn("GET", "/doesnotmatter")
    results = Example.call(conn, [])
    assert results.status == 401
  end

  test "with an invalid token" do
    conn = conn("GET", "/doesnotmatter")
           |> put_req_header("authorization", "Bearer ey.nonsense.foo")
    results = Example.call(conn, [])
    assert results.status == 401
  end

  test "with a valid public token" do
    conn = conn("GET", "/doesnotmatter")
           |> put_req_header("authorization", "Bearer " <> JWT.generate)
    results = Example.call(conn, [])
    assert results.status == 200
    refute results.assigns[:current_user]
  end

  test "with a valid user token" do
    user = Factory.insert(:user)
    conn = conn("GET", "/doesnotmatter")
           |> put_req_header("authorization", "Bearer " <> JWT.generate(user))
    results = Example.call(conn, [])
    assert results.status == 200
    assert results.assigns[:current_user].id == user.id
  end
end
