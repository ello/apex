defmodule Ello.Serve.VersionStore.Redis do
  @behaviour Ello.Serve.VersionStore
  alias __MODULE__.Client

  def fetch_version(app, nil, env) do
    case Client.command(["GET", active_key(app, env)]) do
      {:ok, nil}  -> {:error, :not_found}
      {:ok, html} -> {:ok, html}
      error       -> error
    end
  end
  def fetch_version(app, version, _env) do
    case Client.command(["HGET", app_key(app), version]) do
      {:ok, nil}  -> {:error, :not_found}
      {:ok, html} -> {:ok, html}
      error       -> error
    end
  end

  def put_version(app, version, html) when is_binary(app) and is_binary(version) and is_binary(html) do
    case Client.command(["HSET", app_key(app), version, html]) do
      {:ok, _} -> :ok
      error    -> error
    end
  end

  def activate_version(app, version, env) when is_binary(version) do
    with {:ok, html} <- fetch_version(app, version, env),
         {:ok, _}    <- Client.command(["SET", active_key(app, env), html]) do
      :ok
    else
      error -> error
    end
  end

  defp app_key(app), do: "ello_serve:#{app}:versions"
  defp active_key(app, env), do: "ello_serve:#{app}:#{env}:current"
end
