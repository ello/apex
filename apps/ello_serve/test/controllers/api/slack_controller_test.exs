defmodule Ello.Serve.API.SlackControllerTest do
  use Ello.Serve.ConnCase
  alias Ello.Serve.VersionStore

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "POST /api/serve/v1/slack/action - invalid token", %{conn: conn} do
    payload = %{
      token: "nope nope nope",
      callback_id: "publish:webapp",
      actions: [%{
        name: "test",
        value: "def345",
      }]
    }
    body = %{
      "payload" => URI.encode_www_form(Poison.encode!(payload))
    }
    resp = post(conn, "/api/serve/v1/slack/action", body)
    assert resp.status == 401
  end

  test "POST /api/serve/v1/slack/action - valid", %{conn: conn} do
    VersionStore.put_version("webapp", "def345", "<h1>From slack!</h1>")
    payload = %{
      token: "slack-ello",
      callback_id: "publish:webapp",
      actions: [%{
        name: "test",
        value: "def345",
      }]
    }
    body = %{
      "payload" => URI.encode_www_form(Poison.encode!(payload))
    }
    resp = post(conn, "/api/serve/v1/slack/action", body)
    assert resp.status == 200
    {:ok, html} = VersionStore.fetch_version("webapp", nil)
    assert html =~ "slack!"
  end
end
