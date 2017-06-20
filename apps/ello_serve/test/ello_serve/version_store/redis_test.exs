defmodule Ello.Serve.VersionStore.RedisTest do
  use ExUnit.Case, async: false
  alias Ello.Serve.VersionStore.Redis

  setup do
    Application.put_env(:ello_serve, :version_store_adapter, Redis)
    on_exit fn() ->
      Redis.Client.command(["DEL", "ello_serve:webapp:versions"])
      Redis.Client.command(["DEL", "ello_serve:webapp:test:current"])
      Redis.Client.command(["DEL", "ello_serve:webapp:dev:current"])
      Application.put_env(:ello_serve, :version_store_adapter, Ello.Serve.VersionStore.Memory)
    end
    :ok
  end

  test "versions can be put and fetched" do
    assert :ok = Redis.put_version(:webapp, "abc123", "<h1>Hello</h1>")
    assert {:ok, "<h1>Hello</h1>"} = Redis.fetch_version(:webapp, "abc123", "test")
  end

  test "versions can be activated and fetched" do
    assert :ok = Redis.put_version(:webapp, "abc123", "<h1>Hello</h1>")
    assert :ok = Redis.activate_version(:webapp, "abc123", "test")
    assert {:ok, "<h1>Hello</h1>"} = Redis.fetch_version(:webapp, nil, "test")
  end
end
