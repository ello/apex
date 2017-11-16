defmodule Ello.Serve.Bread.NoContentView do
  use Ello.Serve.Web, :view

  # NoContentController assumes no noscript tags, so skip render.
  def render("noscript.html", _), do: ""
end
