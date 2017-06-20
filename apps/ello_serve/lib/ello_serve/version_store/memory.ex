defmodule Ello.Serve.VersionStore.Memory do
  @behaviour Ello.Serve.VersionStore
  @name :version_memory_store

  def fetch_version(app, nil, env) do
    case Agent.get(@name, &(&1[:active][app][env])) do
      nil  -> {:error, :not_found}
      html -> {:ok, html}
    end
  end
  def fetch_version(app, version, _env) do
    case Agent.get(@name, &(&1[:versions][app][version])) do
      nil  -> {:error, :not_found}
      html -> {:ok, html}
    end
  end

  def put_version(app, version, html) when is_binary(version) and is_binary(html) do
    Agent.update(@name, fn(state) ->
      state
      |> update_in([:versions], &Map.put_new(&1, app, %{}))
      |> update_in([:versions, app], &(Map.put(&1, version, html)))
    end)
    :ok
  end

  def activate_version(app, version, env) when is_binary(version) do
    {:ok, html} = fetch_version(app, version, env)
    Agent.update(@name, fn(state) ->
      state
      |> update_in([:active], &Map.put_new(&1, app, %{}))
      |> update_in([:active, app], &(Map.put(&1, env, html)))
    end)
    :ok
  end

  def start() do
    Agent.start(fn() -> %{active: %{}, versions: %{}} end, name: @name)
  end

  def reset() do
    Agent.update(@name, fn(_state) -> %{active: %{}, versions: %{}} end)
  end
end
