defmodule Ello.V2.Render do
  import Phoenix.Controller, only: [render: 2, render: 4]
  import PhoenixETag, only: [render_if_stale: 4, render_if_stale: 2]
  import Plug.Conn

  defmacrop with_data(conn, opts, do: code) do
    quote do
      opts = Enum.into(unquote(opts), %{})
      conn = unquote(conn)
      # use . notation here to force exception if data key not passed in
      case opts.data do
        nil  -> send_resp(conn, 404, ~s({"error": "Not found"}))
        []   -> send_204(conn)
        data -> unquote(code)
      end
    end
  end

  def api_render(conn, opts) do
    with_data conn, opts do
      render(conn, opts)
    end
  end

  def api_render(conn, view, template, opts) do
    with_data conn, opts do
      render(conn, view, template, opts)
    end
  end

  def api_render_if_stale(conn, opts) do
    with_data conn, opts do
      render_if_stale(conn, opts)
    end
  end

  def api_render_if_stale(conn, view, template, opts) do
    with_data conn, opts do
      render_if_stale(conn, view, template, opts)
    end
  end

  defp send_204(conn) do
    conn
    |> put_resp_header("x-total-pages-remaining", "0")
    |> send_resp(204, "")
  end
end
