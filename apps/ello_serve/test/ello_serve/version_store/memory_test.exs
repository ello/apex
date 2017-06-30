defmodule Ello.Serve.VersionStore.MemoryTest do
  use ExUnit.Case, async: false
  alias Ello.Serve.VersionStore.Memory

  setup do
    Application.put_env(:ello_serve, :version_store_adapter, Memory)
    Memory.start()
    on_exit fn() ->
      Memory.reset()
    end
    :ok
  end

  test "versions can be put and fetched" do
    assert :ok = Memory.put_version("webapp", "abc123", "<h1>Hello</h1>")
    assert {:ok, "<h1>Hello</h1>"} = Memory.fetch_version("webapp", "abc123", "test")
  end

  test "versions can be activated and fetched" do
    assert :ok = Memory.put_version("webapp", "abc123", "<h1>Hello</h1>")
    assert :ok = Memory.activate_version("webapp", "abc123", "test")
    assert {:ok, "<h1>Hello</h1>"} = Memory.fetch_version("webapp", nil, "test")
  end

  test "previous versions are stored" do
    assert :ok = Memory.put_version("webapp", "abc123", "<h1>Hello</h1>")
    assert :ok = Memory.put_version("webapp", "def456", "<h2>Hello</h2>")
    assert [:none] = Memory.version_history("webapp", "test")
    assert :ok = Memory.activate_version("webapp", "abc123", "test")
    assert ["abc123"] = Memory.version_history("webapp", "test")
    assert :ok = Memory.activate_version("webapp", "def456", "test")
    assert ["def456", "abc123"] = Memory.version_history("webapp", "test")
    assert :ok = Memory.activate_version("webapp", "abc123", "test")
    assert ["abc123", "def456", "abc123"] = Memory.version_history("webapp", "test")
  end
end
