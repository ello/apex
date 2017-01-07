defmodule Ello.Dispatch do
  @moduledoc """
  Dispatch HTTP requests to the proper umbrella app.
  """
  use Plug.Builder

  plug :dispatch

  def dispatch(%{path_info: ["ping" | _]} = conn, _),
    do: send_resp(conn, 200, "pong")
  def dispatch(%{path_info: ["v2" | _]} = conn, _),
    do: Ello.V2.Router.call(conn, [])
  def dispatch(conn, _),
    do: send_resp(conn, 404, "Not Found")
end
