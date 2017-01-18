defmodule Ello.V2.ImageViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.ImageView
  alias Ello.Core.Discovery.Category

  test "image.json - rendering an image given model and attribute" do
    assert render(ImageView, "image.json", model: category, attribute: :tile_image) ==
      %{
        "original" => %{
          "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-large-23cb59fe.png",
          "metadata" => %{
            "size"   => 855_144,
            "type"   => "image/png",
            "width"  => 1000,
            "height" => 1000
          }
        },
        "regular" => %{
          "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-regular-23cb59fe.png",
          "metadata" => %{
            "size"   => 556_821,
            "type"   => "image/png",
            "width"  => 800,
            "height" => 800
          }
        },
        "small" => %{
          "url" => "https://assets.ello.co/uploads/category/tile_image/2/ello-small-23cb59fe.png",
          "metadata" => %{
            "size"   => 126_225,
            "type"   => "image/png",
            "width"  => 360,
            "height" => 360
          }
        }
      }
  end

  test "image.json - rendering the default for a category" do
    assert render(ImageView, "image.json", model: %Category{}, attribute: :tile_image) ==
      %{
        "original" => %{
          "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default.png",
          "metadata" => nil,
        },
        "large" => %{
          "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-large.png",
          "metadata" => nil,
        },
        "regular" => %{
          "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-regular.png",
          "metadata" => nil,
        },
        "small" => %{
          "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-small.png",
          "metadata" => nil,
        },
      }
  end

  defp category do 
    Factory.build(:category, %{
      id: 2,
      tile_image: "ello-optimized-8bcedb76.jpg",
      tile_image_metadata: %{
        "large" => %{
          "size"   => 855_144,
          "type"   => "image/png",
          "width"  => 1000,
          "height" => 1000
        },
        "regular" => %{
          "size"   => 556_821,
          "type"   => "image/png",
          "width"  => 800,
          "height" => 800
        },
        "small" => %{
          "size"   => 126_225,
          "type"   => "image/png",
          "width"  => 360,
          "height" => 360
        },
      },
    })
  end
end