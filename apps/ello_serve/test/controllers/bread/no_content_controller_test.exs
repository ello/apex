defmodule Ello.Serve.Bread.NoContentControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.VersionStore

  setup %{conn: conn} do
    :ok = VersionStore.put_version("bread", "v1", "<html><head></head><h1>:bread:</h1></html>")
    :ok = VersionStore.put_version("bread", "v2", "<html><head></head><h1>:beer:</h1></html>")
    VersionStore.activate_version("bread", "v1")
    {:ok, conn: conn}
  end

  test "/manage - it renders - active version", %{conn: conn} do
    resp = get(conn, "/manage")
    html = html_response(resp, 200)
    assert html =~ ":bread:"
  end

  test "/manage/artist-invites - it renders - active version", %{conn: conn} do
    resp = get(conn, "/manage/artist-invites")
    html = html_response(resp, 200)
    assert html =~ ":bread:"
  end

  test "/manage/artist-invites/1 - it renders - new active version", %{conn: conn} do
    VersionStore.activate_version("bread", "v2")
    resp = get(conn, "/manage/artist-invites/1")
    html = html_response(resp, 200)
    assert html =~ ":beer:"
  end

  test "/manage - it renders config", %{conn: conn} do
    resp = get(conn, "/manage")
    html = html_response(resp, 200)
    assert [_, content] = Regex.run(~r{<meta name="breadEnv" content="([^"]*)" />}s, html)
    config = content |> URI.decode() |> Jason.decode!
    assert config["OAUTH_CLIENT_ID"] == "client_id"
  end

  # test "following - it renders config", %{conn: conn} do
  #   resp = get(conn, "/following")
  #   html = html_response(resp, 200)

  #   assert [_, content] = Regex.run(~r{<meta name="webappEnv" content="([^"]*)" />}s, html)
  #   config = content |> URI.decode() |> Jason.decode!
  #   assert config["AUTH_CLIENT_ID"] == "client_id"
  #   assert config["AUTH_DOMAIN"] == "https://ello.co"
  #   assert config["PROMO_HOST"] == "https://d9ww8oh3n3brk.cloudfront.net"
  #   assert config["SEGMENT_WRITE_KEY"] == "segment_key"
  #   assert config["APP_DEBUG"] == false
  #   refute config["HONEYBADGER_API_KEY"]
  # end
end
