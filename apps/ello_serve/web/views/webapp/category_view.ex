defmodule Ello.Serve.Webapp.CategoryView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]

  def category_image_url(%{tile_image_struct: %{path: path, versions: versions}}) do
    version = Enum.find(versions, &(&1.name == "large"))
    image_url(path, version.filename)
  end
end
