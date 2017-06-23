defmodule Ello.Serve.Render do
  import Phoenix.Controller, only: [view_module: 1, html: 2]
  import Phoenix.View, only: [render_to_iodata: 3]
  alias Ello.Serve.Webapp

  def render_html(conn, data \\ [])
  def render_html(%{assigns: %{prerender: false, html: html}} = conn, _) do
    html(conn, inject_config(html, conn))
  end
  def render_html(conn, data) do
    # Execute any functions
    data = Enum.reduce data, %{conn: conn}, fn
      ({key, fun}, accum) when is_function(fun) ->  Map.put(accum, key, fun.())
      ({key, val}, accum) -> Map.put(accum, key, val)
    end
    meta     = render_meta(conn, data)
    noscript = render_noscript(conn, data)
    body     = conn.assigns.html
               |> inject_meta(meta)
               |> inject_noscript(noscript)
               |> inject_config(conn)

    html(conn, body)
  end

  defp render_meta(conn, data) do
    view = view_module(conn)
    render_to_iodata(view, "meta.html", data)
  end

  defp inject_meta(body, meta) do
    String.replace(body, "</head>", "#{meta}</head>", global: false)
  end

  defp render_noscript(conn, data) do
    view = view_module(conn)
    render_to_iodata(view, "noscript.html", data)
  end

  defp inject_noscript(body, noscript) do
    String.replace(body, "</body>", "#{noscript}</body>", global: false)
  end

  defp inject_config(html, %{assigns: %{app: "webapp"}}) do
    config = render_to_iodata(Webapp.ConfigView, "script.html", [])
    String.replace(html, "<body>", "<body>#{config}", global: false)
  end
  defp inject_config(html, _), do: html
end