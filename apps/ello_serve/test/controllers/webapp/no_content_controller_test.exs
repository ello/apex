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
    assert html =~ ~r"<body><script>.*window.webappEnv = {.*</script>"s
    assert html =~ ~r(AUTH_CLIENT_ID:.*"client_id",)s
    assert html =~ ~r(AUTH_DOMAIN:.*"https://ello.co",)s
    assert html =~ ~r(LOGO_MARK:.*"normal",)s
    assert html =~ ~r(PROMO_HOST:.*"https://d9ww8oh3n3brk.cloudfront.net",)s
    assert html =~ ~r(SEGMENT_WRITE_KEY:.*"segment_key")s
    refute html =~ ~r"HONEYBADGER"
  end

  test "following - it renders config - with honeybadger", %{conn: conn} do
    old = Application.get_env(:ello_serve, :webapp_config)
    Application.put_env(:ello_serve, :webapp_config, Keyword.put(old, :honeybadger_api_key, "abc123"))
    resp = get(conn, "/following")
    Application.put_env(:ello_serve, :webapp_config, old)
    html = html_response(resp, 200)
    assert html =~ ~r"<body><script>.*window.webappEnv = {.*</script>"s
    assert html =~ ~r(AUTH_CLIENT_ID:.*"client_id",)s
    assert html =~ ~r(AUTH_DOMAIN:.*"https://ello.co",)s
    assert html =~ ~r(LOGO_MARK:.*"normal",)s
    assert html =~ ~r(PROMO_HOST:.*"https://d9ww8oh3n3brk.cloudfront.net",)s
    assert html =~ ~r(SEGMENT_WRITE_KEY:.*"segment_key")s
    assert html =~ ~r(HONEYBADGER_API_KEY:.*"abc123")s
    assert html =~ ~r(HONEYBADGER_ENVIRONMENT:.*"production")s
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
    assert html =~ ~r"<body><script>.*window.webappEnv = {.*</script>"s
  end

  test "following - skip prerender via cookie", %{conn: conn} do
    resp = conn
           |> put_req_cookie("ello_skip_prerender", "true")
           |> get("/following")
    html = html_response(resp, 200)
    # No title etc
    refute html =~ "Ello | The Creators Network"
    # Has config
    assert html =~ ~r"<body><script>.*window.webappEnv = {.*</script>"s
  end

  test "notifications", %{conn: conn} do
    resp = get(conn, "/notifications")
    html = html_response(resp, 200)
    # No title etc
    assert html =~ "Ello | The Creators Network"
    # Has config
    assert html =~ ~r"<body><script>.*window.webappEnv = {.*</script>"s
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
  test "forgot - it renders - active version", %{conn: conn} do
    resp = get(conn, "/forgot")
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
    assert has_meta(html, name: "apple-itunes-app", content: "app-id=1234567")
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
