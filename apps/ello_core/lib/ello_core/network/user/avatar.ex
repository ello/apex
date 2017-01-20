defmodule Ello.Core.Network.User.Avatar do
  defstruct [user: nil, filename: nil, path: nil, versions: []]

  defmodule Version do
    defstruct [name: nil, width: nil, height: nil, size: nil, type: nil, filename: nil]

    def from_metadata(metadata, original_filename) do
      Enum.map metadata, fn({name, properties}) ->
        %__MODULE__{
          name: name,
          width: properties["width"],
          height: properties["height"],
          size: properties["size"],
          type: properties["type"],
          filename: properties["filename"] || filename(original_filename, name, properties["type"]),
        }
      end
    end

    defp filename(original_filename, version_name, type) do
      version_name = String.replace(version_name, "_", "-")
      hash         = hash_name(original_filename)
      ext          = extension(type)
      Enum.join(["ello", version_name, hash], "-") <> ext
    end

    # MD5 of value stored in db, minus the file extension
    defp hash_name(name) do
      name
      |> String.split(".")
      |> hd
      |> :erlang.md5
      |> Base.encode16(case: :lower)
      |> String.slice(0..7)
    end

    defp extension("image/png"), do: ".png"
    defp extension("image/jpeg"), do: ".jpg"
    defp extension("image/gif"), do: ".gif"
    defp extension(_), do: ".png"
  end


  def build(user) do
    Map.put(user, :avatar_struct, do_build(user))
  end

  # Default
  defp do_build(%{avatar: nil} = user) do
    path = "images/fallback/user/avatar/#{default_image_id(user.id)}"
    %__MODULE__{
      user:     user,
      filename: "ello-default.png",
      path:     "images/fallback/user/avatar/#{default_image_id(user.id)}",
      versions: Version.from_metadata(%{
        "large"   => %{"filename" => "#{path}/ello-default-large.png"},
        "regular" => %{"filename" => "#{path}/ello-default-regular.png"},
        "small"   => %{"filename" => "#{path}/ello-default-small.png"},
      }, nil)
    }
  end

  defp do_build(user) do
    %__MODULE__{
      user:     user,
      filename: user.avatar,
      path:     "/uploads/user/avatar/#{user.id}",
      versions: Version.from_metadata(user.avatar_metadata, user.avatar),
    }
  end

  @default_avatar_images 48
  defp default_image_id(nil), do: 1
  defp default_image_id(id) do
    Integer.mod(id, @default_avatar_images)
  end
end
