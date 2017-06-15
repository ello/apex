defmodule Ello.Serve.Webapp.NoContentView do
  use Ello.Serve.Web, :view

  # NoContentController assumes no noscript tags, so skip render.
  def render("noscript.html", _), do: ""
end
