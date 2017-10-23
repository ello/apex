defmodule Ello.Serve.SkipPrerender do
  use Plug.Builder

  plug :do_fetch_cookies
  plug :set_prerender
  plug :set_logged_in_user
  plug :set_debug

  def do_fetch_cookies(conn, _), do: fetch_cookies(conn)

  defp set_prerender(%{params: %{"prerender" => "false"}} = conn, _),
    do: assign(conn, :prerender, false)
  defp set_prerender(%{cookies: %{"ello_skip_prerender" => "true"}} = conn, _),
    do: assign(conn, :prerender, false)
  defp set_prerender(%{assigns: %{app: app}} = conn, _)
    when app in ['bread', 'curator'],
    do: assign(conn, :prerender, false)
  defp set_prerender(conn, _),
    do: assign(conn, :prerender, true)

  defp set_logged_in_user(%{cookies: %{"ello_skip_prerender" => "true"}} = conn, _),
    do: assign(conn, :logged_in_user?, true)
  defp set_logged_in_user(conn, _),
    do: assign(conn, :logged_in_user?, false)

  defp set_debug(%{params: %{"debug" => "true"}} = conn, _),
    do: assign(conn, :debug, true)
  defp set_debug(%{params: %{"debug" => "false"}} = conn, _),
    do: assign(conn, :debug, false)
  defp set_debug(conn, _), do: conn
end
