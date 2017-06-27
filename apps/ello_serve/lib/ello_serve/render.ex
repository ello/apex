defmodule Ello.Serve.Render do
  import Phoenix.Controller, only: [view_module: 1, html: 2]
  import Phoenix.View, only: [render_to_iodata: 3]
  import NewRelicPhoenix, only: [measure_segment: 2]
  alias Ello.Serve.Webapp

  def render_html(conn, data \\ [])
  def render_html(%{assigns: %{prerender: false, html: html}} = conn, data) do
    config = render_config(conn, data)
    measure_segment {__MODULE__, :inject_without_prerender} do
      html = inject_config(html, config)
    end
    html(conn, html)
  end
  def render_html(conn, data) do
    # Execute any functions
    measure_segment {__MODULE__, :lazy_load} do
      data = Enum.reduce data, %{conn: conn}, fn
        ({key, fun}, accum) when is_function(fun) -> Map.put(accum, key, fun.())
        ({key, val}, accum) -> Map.put(accum, key, val)
      end
    end

    meta     = render_meta(conn, data)
    noscript = render_noscript(conn, data)
    config   = render_config(conn, data)

    measure_segment {__MODULE__, :inject} do
      body = conn.assigns.html
             |> inject_meta(meta)
             |> inject_noscript(noscript)
             |> inject_config(config)
    end

    html(conn, body)
  end

  defp render_meta(conn, data) do
    measure_segment {:render, "meta.html"} do
      view = view_module(conn)
      render_to_iodata(view, "meta.html", data)
    end
  end

  defp inject_meta(body, meta) do
    String.replace(body, "</head>", "#{meta}</head>", global: false)
  end

  defp render_noscript(conn, data) do
    measure_segment {:render, "noscript.html"} do
      view = view_module(conn)
      data = Map.put(data, :layout, {Webapp.NoscriptView, "layout.html"})
      render_to_iodata(view, "noscript.html", data)
    end
  end

  defp inject_noscript(body, noscript) do
    String.replace(body, "</body>", "#{noscript}</body>", global: false)
  end

  defp render_config(%{assigns: %{app: "webapp"}}, _) do
    measure_segment {:render, "config.html"} do
      render_to_iodata(Webapp.ConfigView, "script.html", [])
    end
  end
  defp render_config(_, _), do: ""

  defp inject_config(html, config) do
    String.replace(html, "<body>", "<body>#{config}", global: false)
  end
end
