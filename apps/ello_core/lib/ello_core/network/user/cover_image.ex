defmodule Ello.Core.Network.User.CoverImage do
  alias Ello.Core.{Image, Network.User}

  @spec from_user(user :: User.t) :: Image.t
  def from_user(%{cover_image: nil} = user) do
    %Image{
      user:     user,
      filename: "ello-default.jpg",
      path:     "images/fallback/user/cover_image/#{default_image_id(user.id)}",
      versions: Image.Version.from_metadata(%{
        "optimized" => %{"filename" => "ello-default-optimized.jpg"},
        "xhdpi"     => %{"filename" => "ello-default-xhdpi.jpg"},
        "hdpi"      => %{"filename" => "ello-default-hdpi.jpg"},
        "ldpi"      => %{"filename" => "ello-default-ldpi.jpg"},
        "mdpi"      => %{"filename" => "ello-default-mdpi.jpg"},
      }, nil)
    }
  end

  def from_user(user) do
    %Image{
      user:     user,
      filename: user.cover_image,
      path:     "/uploads/user/cover_image/#{user.id}",
      versions: Image.Version.from_metadata_with_defaults(%{
        metadata: user.cover_image_metadata,
        original: user.cover_image,
        required_versions: [:optimized, :xhdpi, :hdpi],
        default_type: "image/jpg",
      }),
    }
  end

  @default_cover_images 33
  defp default_image_id(nil), do: 1
  defp default_image_id(id) do
    case Integer.mod(id, @default_cover_images) do
      0 -> 1
      n -> n
    end
  end
end
