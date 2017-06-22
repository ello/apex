defmodule Ello.Serve.API.VersionControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.VersionStore

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "POST /api/serve/v1/versions - valid - with auth", %{conn: conn} do
    body = %{
      "html"    => "<h1>Ello!</h1>",
      "app"     => "webapp",
      "version" => "twopointoh",
    }
    resp = conn
           |> put_req_header("authorization", "Basic #{basic_auth_header()}")
           |> post("/api/serve/v1/versions", body)
    assert resp.status == 201
    assert {:ok, "<h1>" <> _} = VersionStore.fetch_version("webapp", "twopointoh")
  end

  test "POST /api/serve/v1/versions - invalid - with auth", %{conn: conn} do
    body = %{
      "html"    => "<h1>Ello!</h1>",
      "version" => "twopointoh",
    }
    assert_raise FunctionClauseError, fn ->
      conn
      |> put_req_header("authorization", "Basic #{basic_auth_header()}")
      |> post("/api/serve/v1/versions", body)
    end
  end

  test "POST /api/serve/v1/versions - valid - without auth", %{conn: conn} do
    body = %{
      "html"    => "<h1>Ello!</h1>",
      "app"     => "webapp",
      "version" => "twopointoh",
    }
    resp = post(conn, "/api/serve/v1/versions", body)
    assert resp.status == 401
    assert ["Basic" <> _] = get_resp_header(resp, "www-authenticate")
  end

  test "POST /api/serve/v1/versions/activate - valid - with auth", %{conn: conn} do
    :ok = VersionStore.put_version("webapp", "onepointoh", "<h1>Ello</h1>")
    :ok = VersionStore.put_version("webapp", "twopointoh", "<h2>Ello</h2>")
    :ok = VersionStore.activate_version("webapp", "onepointoh")
    assert {:ok, "<h1>" <> _} = VersionStore.fetch_version("webapp", nil)
    body = %{
      "app"         => "webapp",
      "version"     => "twopointoh",
      "environment" => "test",
    }
    resp = conn
           |> put_req_header("authorization", "Basic #{basic_auth_header()}")
           |> post("/api/serve/v1/versions/activate", body)
    assert resp.status == 200
    assert {:ok, "<h2>" <> _} = VersionStore.fetch_version("webapp", nil)
  end

  defp basic_auth_header() do
    Base.encode64(
      Application.get_env(:ello_serve, :api_username)
      <> ":" <>
      Application.get_env(:ello_serve, :api_password)
    )
  end
end
