defmodule Ello.Serve.SetApp do
  @moduledoc """
  Set the application name in assigns.

  We can then use that to know what app we are serving. Called via plug/router:

      plug ElloServer.SetApp, app: :webapp

      # or

      plug ElloServer.SetApp, app: :curator

  """
  @behaviour Plug
  import Plug.Conn

  def init(opts) do
    case opts[:app] do
      nil -> raise "Must pass app as argument"
      _   -> opts
    end
  end

  def call(conn, opts), do: assign(conn, :app, opts[:app])
end
