defmodule Ello.Serve.FetchVersion do
  @moduledoc """
  Determines the version to load, then loads it from redis.

  If the query param `?version=abcdef` is present that version is requested,
  otherwise the current live version is assumed.

  If version is not found a 404 is returned.
  """
  use Plug.Builder

  plug :set_version
  plug :load_html

  def set_version(%{params: %{"version" => version}} = conn, _) do
    assign(conn, :version, version)
  end
  def set_version(conn, _) do
    assign(conn, :version, "current")
  end

  #TODO: Switch to our own redis
  alias Ello.Core.Redis

  def load_html(conn, _) do
    version_key = "ello_serve:#{conn.assigns.app}:#{conn.assigns.version}"
    case Redis.command(["GET", version_key]) do
      {:ok, nil}  -> halt send_resp(conn, 404, "version not found")
      {:ok, html} -> assign(conn, :html, html)
    end
  end
end
