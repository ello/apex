defmodule Ello.Core.Content.Asset.Attachment do
  alias Ello.Core.Image
  alias Ello.Core.Content.Asset

  @spec from_asset(asset :: Asset.t) :: Image.t
  def from_asset(asset) do
    %Image{
      filename: asset.attachment,
      path:     "/uploads/asset/attachment/#{asset.id}",
      versions: Image.Version.from_metadata(asset.attachment_metadata, asset.attachment),
    }
  end
end
