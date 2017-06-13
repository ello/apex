defmodule Ello.Serve.Render do
  import Phoenix.Controller, only: [view_module: 1, html: 2]
  import Phoenix.View, only: [render_to_iodata: 3]

  def render_html(conn, data \\ []) do
    data     = Enum.into(data, %{})
    meta     = render_meta(conn, data)
    noscript = render_noscript(conn, data)
    body     = conn.assigns.html
               |> inject_meta(meta)
               |> inject_noscript(noscript)
    html(conn, body)
  end

  defp render_meta(conn, data) do
    view = view_module(conn)
    render_to_iodata(view, "meta.html", Map.put(data, :conn, conn))
  end

  defp inject_meta(body, meta) do
    String.replace(body, "</head>", "#{meta}</head>", global: false)
  end

  # TODO: skip noscript if known user with javascript (eg, skip prerender cookie set)
  defp render_noscript(conn, data) do
    view = view_module(conn)
    render_to_iodata(view, "noscript.html", Map.put(data, :conn, conn))
  end

  defp inject_noscript(body, noscript) do
    String.replace(body, "</body>", "#{noscript}</body>", global: false)
  end
end
