defmodule Ello.V2.ClientPropertiesTest do
  use Ello.V2.ConnCase
  alias Ello.V2.ClientProperties
  alias Ello.Core.Network.User

  test "detects android", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello Android")
           |> ClientProperties.call([])
    assert conn.assigns[:android]
    refute conn.assigns[:ios_version]
    refute conn.assigns[:ios]
    refute conn.assigns[:webapp]
  end

  test "detects ios from user agent", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello/4640 CFNetwork/758.3.15 Darwin/15.5.0")
           |> ClientProperties.call([])
    assert conn.assigns[:ios_version] == 4640
    assert conn.assigns[:ios]
    refute conn.assigns[:android]
    refute conn.assigns[:webapp]
  end

  test "detects ios from build header", %{conn: conn} do
    conn = conn
           |> put_req_header("x-ios-build-number", "4640")
           |> ClientProperties.call([])
    assert conn.assigns[:ios_version] == 4640
    assert conn.assigns[:ios]
    refute conn.assigns[:android]
    refute conn.assigns[:webapp]
  end

  test "detects webapp", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Chrome")
           |> ClientProperties.call([])
    assert conn.assigns[:webapp]
    refute conn.assigns[:android]
    refute conn.assigns[:ios_version]
    refute conn.assigns[:ios]
  end

  test "allows nudity/nsfw - no user - webapp", %{conn: conn} do
    conn = conn
           |> assign(:webapp, true)
           |> ClientProperties.call([])
    assert conn.assigns[:webapp]
    assert conn.assigns[:allow_nudity]
    assert conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - no user - android", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello Android")
           |> ClientProperties.call([])
    assert conn.assigns[:android]
    refute conn.assigns[:allow_nudity]
    refute conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - no user - ios", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello/4640 CFNetwork/758.3.15 Darwin/15.5.0")
           |> ClientProperties.call([])
    assert conn.assigns[:ios]
    refute conn.assigns[:allow_nudity]
    refute conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user views nsfw - webapp", %{conn: conn} do
    conn = conn
           |> assign(:webapp, true)
           |> assign(:current_user, %User{settings: %{views_adult_content: true}})
           |> ClientProperties.call([])
    assert conn.assigns[:webapp]
    assert conn.assigns[:allow_nudity]
    assert conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user does not view nsfw - webapp", %{conn: conn} do
    conn = conn
           |> assign(:webapp, true)
           |> assign(:current_user, %User{settings: %{views_adult_content: false}})
           |> ClientProperties.call([])
    assert conn.assigns[:webapp]
    assert conn.assigns[:allow_nudity]
    refute conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user views nsfw - android", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello Android")
           |> assign(:current_user, %User{settings: %{views_adult_content: true}})
           |> ClientProperties.call([])
    assert conn.assigns[:android]
    assert conn.assigns[:allow_nudity]
    assert conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user does not view nsfw - android", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello Android")
           |> assign(:current_user, %User{settings: %{views_adult_content: false}})
           |> ClientProperties.call([])
    assert conn.assigns[:android]
    refute conn.assigns[:allow_nudity]
    refute conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user views nsfw - ios", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello/4640 CFNetwork/758.3.15 Darwin/15.5.0")
           |> assign(:current_user, %User{settings: %{views_adult_content: true}})
           |> ClientProperties.call([])
    assert conn.assigns[:ios]
    assert conn.assigns[:allow_nudity]
    assert conn.assigns[:allow_nsfw]
  end

  test "allows nudity/nsfw - user does not view nsfw - ios", %{conn: conn} do
    conn = conn
           |> put_req_header("user_agent", "Ello/4640 CFNetwork/758.3.15 Darwin/15.5.0")
           |> assign(:current_user, %User{settings: %{views_adult_content: false}})
           |> ClientProperties.call([])
    assert conn.assigns[:ios]
    refute conn.assigns[:allow_nudity]
    refute conn.assigns[:allow_nsfw]
  end
end
