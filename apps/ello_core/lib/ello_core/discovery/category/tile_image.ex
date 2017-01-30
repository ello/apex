defmodule Ello.Core.Discovery.Category.TileImage do
  alias Ello.Core.Image
  alias Ello.Core.Discovery.Category

  @spec from_category(category :: Category.t) :: Image.t
  def from_category(%{tile_image: nil}) do
    %Image{
      filename: "ello-default.png",
      path:     "images/fallback/category/tile_image/",
      versions: Image.Version.from_metadata(%{
        "large"   => %{"filename" => "ello-default-large.png"},
        "regular" => %{"filename" => "ello-default-regular.png"},
        "small"   => %{"filename" => "ello-default-small.png"},
      }, nil)
    }
  end

  def from_category(category) do
    %Image{
      filename: category.tile_image,
      path:     "/uploads/category/tile_image/#{category.id}",
      versions: Image.Version.from_metadata(category.tile_image_metadata, category.tile_image),
    }
  end
end
