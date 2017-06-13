defmodule Ello.Serve.Webapp.PostView do
  use Ello.Serve.Web, :view

  def render("block.html", %{block: %{"kind" => "image"}} = assigns),
    do: render("image_block.html", assigns)

  def render("block.html", %{block: %{"kind" => "text"}} = assigns),
    do: render("html_block.html", assigns)
end
