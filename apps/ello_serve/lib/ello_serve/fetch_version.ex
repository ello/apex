defmodule Ello.Serve.FetchVersion do
  @moduledoc """
  Determines the version to load, then loads it from redis.

  If the query param `?version=abcdef` is present that version is requested,
  otherwise the current live version is assumed.

  If version is not found a 404 is returned.
  """
  use Plug.Builder
  alias Ello.Serve.VersionStore

  plug :set_version
  plug :load_html

  def set_version(%{params: %{"version" => version}} = conn, _) do
    assign(conn, :version, version)
  end
  def set_version(conn, _) do
    assign(conn, :version, nil)
  end

  def load_html(conn, _) do
    case VersionStore.fetch_version(conn.assigns.app, conn.assigns.version) do
      {:ok, html} -> assign(conn, :html, html)
      _           -> halt send_resp(conn, 404, "version not found")
    end
  end
end
