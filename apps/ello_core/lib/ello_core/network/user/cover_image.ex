defmodule Ello.Core.Network.User.CoverImage do
  alias Ello.Core.{Image, Network.User}

  @spec from_user(user :: User.t) :: Image.t
  def from_user(%{cover_image: nil} = user) do
    path = "images/fallback/user/cover_image/#{default_image_id(user.id)}"
    %Image{
      user:     user,
      filename: "ello-default.png",
      path:     "images/fallback/user/cover_image/#{default_image_id(user.id)}",
      versions: Image.Version.from_metadata(%{
        "large"   => %{"filename" => "#{path}/ello-default-large.png"},
        "regular" => %{"filename" => "#{path}/ello-default-regular.png"},
        "small"   => %{"filename" => "#{path}/ello-default-small.png"},
      }, nil)
    }
  end

  def from_user(user) do
    %Image{
      user:     user,
      filename: user.cover_image,
      path:     "/uploads/user/cover_image/#{user.id}",
      versions: Image.Version.from_metadata(user.cover_image_metadata, user.cover_image),
    }
  end

  @default_cover_images 30
  defp default_image_id(nil), do: 1
  defp default_image_id(id) do
    Integer.mod(id, @default_cover_images)
  end
end
