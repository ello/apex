defmodule Ello.Serve.Webapp.NoContentControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.VersionStore

  setup %{conn: conn} do
    raw2 = File.read!("test/support/ello.co.2.html")
    :ok = VersionStore.put_version("webapp", "abc123", raw2)
    {:ok, conn: conn}
  end

  test "following - it renders - active version", %{conn: conn} do
    resp = get(conn, "/following")
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert html =~ "@elloworld"
  end

  test "following - it renders config", %{conn: conn} do
    resp = get(conn, "/following")
    html = html_response(resp, 200)

    assert [_, content] = Regex.run(~r{<meta name="webappEnv" content="([^"]*)" />}s, html)
    config = content |> URI.decode() |> Poison.decode!
    assert config["AUTH_CLIENT_ID"] == "client_id"
    assert config["AUTH_DOMAIN"] == "https://ello.co"
    assert config["PROMO_HOST"] == "https://d9ww8oh3n3brk.cloudfront.net"
    assert config["SEGMENT_WRITE_KEY"] == "segment_key"
    assert config["APP_DEBUG"] == false
    refute config["HONEYBADGER_API_KEY"]
  end

  test "following - it renders config - with honeybadger", %{conn: conn} do
    old = Application.get_env(:ello_serve, :webapp_config)
    Application.put_env(:ello_serve, :webapp_config, Keyword.put(old, :honeybadger_api_key, "abc123"))
    resp = get(conn, "/following")
    Application.put_env(:ello_serve, :webapp_config, old)
    html = html_response(resp, 200)

    assert [_, content] = Regex.run(~r{<meta name="webappEnv" content="([^"]*)" />}s, html)
    config = content |> URI.decode() |> Poison.decode!
    assert config["HONEYBADGER_API_KEY"] == "abc123"
    assert config["HONEYBADGER_ENVIRONMENT"] == "production"
  end

  test "following - it renders config - with debug flag", %{conn: conn} do
    resp = get(conn, "/following", %{"debug" => "false"})
    html = html_response(resp, 200)
    assert [_, content] = Regex.run(~r{<meta name="webappEnv" content="([^"]*)" />}s, html)
    config = content |> URI.decode() |> Poison.decode!
    assert config["APP_DEBUG"] == false

    resp = get(conn, "/following", %{"debug" => "true"})
    html = html_response(resp, 200)
    assert [_, content] = Regex.run(~r{<meta name="webappEnv" content="([^"]*)" />}s, html)
    config = content |> URI.decode() |> Poison.decode!
    assert config["APP_DEBUG"] == true
  end

  test "following - it renders - preview version", %{conn: conn} do
    resp = get(conn, "/following", %{"version" => "abc123"})
    html = html_response(resp, 200)
    assert html =~ "Ello | The Creators Network"
    assert html =~ "@ellohype"
  end

  test "following - skip prerender via param", %{conn: conn} do
    resp = get(conn, "/following", %{"prerender" => "false"})
    html = html_response(resp, 200)
    # No title etc
    refute html =~ "Ello | The Creators Network"
    # Has config
    assert html =~ ~r(<meta name="webappEnv" content="[^"]*" />)
  end

  test "following - skip prerender via cookie", %{conn: conn} do
    resp = conn
           |> put_req_cookie("ello_skip_prerender", "true")
           |> get("/following")
    html = html_response(resp, 200)
    # No title etc
    refute html =~ "Ello | The Creators Network"
    # Has config
    assert html =~ ~r(<meta name="webappEnv" content="[^"]*" />)
  end

  test "notifications", %{conn: conn} do
    resp = get(conn, "/notifications")
    html = html_response(resp, 200)
    # No title etc
    assert html =~ "Ello | The Creators Network"
    # Has config
    assert html =~ ~r(<meta name="webappEnv" content="[^"]*" />)
  end

  @tag :meta
  test "enter - it renders - active version", %{conn: conn} do
    resp = get(conn, "/enter")
    html = html_response(resp, 200)
    assert html =~ "Login | Ello"
    assert has_meta(html, name: "description", content: "Welcome back to Ello.*")
  end

  @tag :meta
  test "join - it renders - active version", %{conn: conn} do
    resp = get(conn, "/join")
    html = html_response(resp, 200)
    assert html =~ "Sign up | Ello"
    assert has_meta(html, name: "description", content: "Join .*")
  end

  @tag :meta
  test "forgot-password - it renders - active version", %{conn: conn} do
    resp = get(conn, "/forgot-password")
    html = html_response(resp, 200)
    assert html =~ "Forgot Password | Ello"
    assert has_meta(html, name: "description", content: "Welcome back .*")
  end

  @tag :meta
  test "default meta", %{conn: conn} do
    resp = get(conn, "/following")
    html = html_response(resp, 200)

    default_desc = "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about."
    default_title = "Ello | The Creators Network"
    default_image = "/static/images/support/ello-open-graph-image.png"

    assert html =~ "<title>Ello | The Creators Network</title>"
    assert has_meta(html, name: "apple-itunes-app", content: "app-id=1234567, app-argument=/following")
    assert has_meta(html, name: "name", content: default_title)
    assert has_meta(html, name: "url", content: "https://ello.co/following")
    assert has_meta(html, name: "description", content: default_desc)
    assert has_meta(html, name: "image", content: default_image)

    assert has_meta(html, property: "og:url", content: "https://ello.co/following")
    assert has_meta(html, property: "og:title", content: default_title)
    assert has_meta(html, property: "og:description", content: default_desc)

    assert has_meta(html, property: "og:image", content: default_image)
    assert has_meta(html, name: "twitter:card", content: "summary_large_image")
    refute has_meta(html, name: "robots")
  end
end
