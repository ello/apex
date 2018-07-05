defmodule Ello.Core.AttachmentTest do
  use Ello.Core.Case
  alias Ello.Core.{Content.Asset.Attachment, Image}

  test "Attachment.from_asset/1 - builds an Image" do
    asset = Factory.build(:asset)
    image = Attachment.from_asset(asset)

    assert %Image{versions: versions} = image
    optimized_test = asset.attachment_metadata["optimized"]
    assert Enum.any?(versions, fn(version) ->
      version.name == "optimized"
      && version.size == optimized_test["size"]
      && version.width == optimized_test["width"]
      && version.height == optimized_test["height"]
      && version.height == optimized_test["height"]
      && version.type == optimized_test["type"]
    end)
  end

  test "Attachment.from_asset/1 - builds required versions when meta missing" do
    asset = Factory.build(:asset, attachment_metadata: %{})
    image = Attachment.from_asset(asset)

    assert %Image{versions: versions} = image
    version_names = Enum.map(versions, &(&1.name))
    assert "optimized" in version_names
    assert "xhdpi" in version_names
    assert "hdpi" in version_names
    optimized = Enum.find(versions, &(&1.name == "optimized"))
    assert optimized.type == "image/jpeg"
    assert String.match?(optimized.filename, ~r/ello-optimized-.*\.jpg/)
  end
end
