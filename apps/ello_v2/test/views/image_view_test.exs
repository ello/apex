defmodule Ello.V2.ImageViewTest do
  use Ello.V2.ConnCase
  import Phoenix.View #For render/2
  alias Ello.V2.ImageView
  alias Ello.Core.Image

  test "image.json - rendering an image given an image struct" do
    assert render(ImageView, "image.json", image: image(), conn: build_conn()) ==
      %{
        "original" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/2/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/2/ello-large-23cb59fe.png",
          metadata: %{
            size:   855_144,
            type:   "image/png",
            width:  1000,
            height: 1000
          }
        },
        "regular" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/2/ello-regular-23cb59fe.png",
          metadata: %{
            size:   556_821,
            type:   "image/png",
            width:  800,
            height: 800
          }
        },
        "small" => %{
          url: "https://assets.ello.co/uploads/category/tile_image/2/ello-small-23cb59fe.png",
          metadata: %{
            size:   126_225,
            type:   "image/png",
            width:  360,
            height: 360
          }
        }
      }
  end

  test "image.json - rendering an image given the image- with domain sharding" do
    Application.put_env(:ello_v2, :asset_host, "https://assets%d.ello.co")
    assert render(ImageView, "image.json", image: image(), conn: build_conn()) ==
      %{
        "original" => %{
          url: "https://assets1.ello.co/uploads/category/tile_image/2/ello-optimized-8bcedb76.jpg"
        },
        "large" => %{
          url: "https://assets2.ello.co/uploads/category/tile_image/2/ello-large-23cb59fe.png",
          metadata: %{
            size:   855_144,
            type:   "image/png",
            width:  1000,
            height: 1000
          }
        },
        "regular" => %{
          url: "https://assets0.ello.co/uploads/category/tile_image/2/ello-regular-23cb59fe.png",
          metadata: %{
            size:   556_821,
            type:   "image/png",
            width:  800,
            height: 800
          }
        },
        "small" => %{
          url: "https://assets0.ello.co/uploads/category/tile_image/2/ello-small-23cb59fe.png",
          metadata: %{
            size:   126_225,
            type:   "image/png",
            width:  360,
            height: 360
          }
        }
      }
    Application.put_env(:ello_v2, :asset_host, "https://assets.ello.co")
  end


  defp image do
    %Image{
      filename: "ello-optimized-8bcedb76.jpg",
      path:     "/uploads/category/tile_image/2",
      versions: Image.Version.from_metadata(%{
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
      }, "ello-optimized-8bcedb76.jpg"),
    }
  end
end
