defmodule Ello.Dispatch do
  @moduledoc """
  Dispatch HTTP requests to the proper umbrella app.
  """
  alias Ello.Dispatch.ErrorView
  alias Phoenix.Controller

  use Plug.Builder
  use Honeybadger.Plug

  plug :dispatch

  def dispatch(%{path_info: ["ping" | _]} = conn, _),
    do: send_resp(conn, 200, "pong")
  def dispatch(%{path_info: ["api", "v2" | _]} = conn, _),
    do: Ello.V2.Router.call(conn, [])
  def dispatch(%{method: "GET"} = conn, _),
    do: Ello.Serve.Router.call(conn, [])
  def dispatch(conn, _),
    do: Controller.render(conn, ErrorView, "404.json")
end
