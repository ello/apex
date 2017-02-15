defmodule Ello.Core.AssetTest do
  use Ello.Core.Case
  alias Ello.Core.{ Image,Content.Asset }

  test "Asset.build_attachment/2 - builds an image attachment" do
    asset = Factory.build(:asset)
    asset_with_image = Asset.build_attachment(asset)
    assert %Image{} = asset_with_image.attachment_struct
  end

end
