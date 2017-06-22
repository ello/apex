defmodule Ello.Serve.VersionStore do
  @type app :: String.t
  @type version :: String.t
  @type html :: String.t
  @type environment :: String.t

  @doc """
  Get the html for the specific app/version.

  If version is nil, fallsback to the active version for the current environment.
  """
  @callback fetch_version(app, version, environment) :: {:ok, html} | {:error, String.t}

  @doc """
  Set the html for the specific app/version.

  Environment independent.
  """
  @callback put_version(app, version, html) :: :ok | :error

  @doc """
  Activate the provided version in the designated environment.
  """
  @callback activate_version(app, version, environment) :: :ok | :error

  @doc "Pass fetch_version/2 to current adapter"
  def fetch_version(app, ver \\ nil, env \\ nil)
  def fetch_version(app, ver, nil) do
    fetch_version(app, ver, Application.get_env(:ello_serve, :current_environment))
  end
  def fetch_version(app, ver, env) do
    verify_env!(env)
    adapter().fetch_version(app, ver, env)
  end

  @doc "Pass put_version/2 to current adapter"
  def put_version(app, ver, html), do: adapter().put_version(app, ver, html)

  @doc "Pass activate_version/2 to current adapter - default to current env"
  def activate_version(app, ver, env \\ nil)
  def activate_version(app, ver, nil) do
    activate_version(app, ver, Application.get_env(:ello_serve, :current_environment))
  end
  def activate_version(app, ver, env) do
    verify_env!(env)
    adapter().activate_version(app, ver, env)
  end

  @doc """
  The adapter in use, must implement Ello.Serve.VersionStore behaviour.
  """
  def adapter() do
    Application.get_env(:ello_serve, :version_store_adapter, __MODULE__.Redis)
  end

  def verify_env!(env) do
    unless env in Application.get_env(:ello_serve, :environments) do
      raise "invalid environment"
    end
  end
end
