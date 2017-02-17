defmodule Ello.V2.AssetViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.AssetView
  alias Ello.Core.Content.{Asset}

  setup %{conn: conn} do
    asset = Factory.build(:asset, %{id: 1})
    {:ok, [
      conn: conn,
      asset: Asset.build_attachment(asset),
    ]}
  end

  test "asset.json - it renders an asset", %{asset: asset} = conn do
    assert %{
      id: "1",
      attachment: %{
        "original" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-a9c0ede1-aeca-45af-9723-5750babf541e.jpeg",
        },
        "optimized" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-optimized-081e2121.jpg",
          metadata: %{height: 1024, size: 433286, type: "image/jpeg", width: 1280},
        },
        "xhdpi" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-xhdpi-081e2121.jpg",
          metadata: %{height: 1024, size: 434916, type: "image/jpeg", width: 1280},
        },
        "hdpi" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-hdpi-081e2121.jpg",
          metadata: %{height: 600, size: 287932, type: "image/jpeg", width: 750},
        },
        "mdpi" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-mdpi-081e2121.jpg",
          metadata: %{height: 300, size: 77422, type: "image/jpeg", width: 375},
        },
        "ldpi" => %{
          url: "https://assets.ello.co/uploads/asset/attachment/1/ello-ldpi-081e2121.jpg",
          metadata: %{height: 144, size: 19718, type: "image/jpeg", width: 180},
        },
      }
    } = render(AssetView, "asset.json",
      asset: asset,
      conn: conn
    )
  end

end
