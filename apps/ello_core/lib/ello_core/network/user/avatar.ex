defmodule Ello.Core.Network.User.Avatar do
  alias Ello.Core.{Image, Network.User}

  @spec from_user(user :: User.t) :: Image.t
  def from_user(%{avatar: nil} = user) do
    %Image{
      user:     user,
      filename: "ello-default.png",
      path:     "images/fallback/user/avatar/#{default_image_id(user.id)}",
      versions: Image.Version.from_metadata(%{
        "large"   => %{"filename" => "ello-default-large.png"},
        "regular" => %{"filename" => "ello-default-regular.png"},
        "small"   => %{"filename" => "ello-default-small.png"},
      }, nil)
    }
  end

  def from_user(user) do
    %Image{
      user:     user,
      filename: user.avatar,
      path:     "/uploads/user/avatar/#{user.id}",
      versions: Image.Version.from_metadata(user.avatar_metadata, user.avatar),
    }
  end

  @default_avatar_images 47
  defp default_image_id(nil), do: 1
  defp default_image_id(id) do
    case Integer.mod(id, @default_avatar_images) do
      0 -> 1
      n -> n
    end
  end
end
