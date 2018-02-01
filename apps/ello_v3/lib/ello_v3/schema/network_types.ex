defmodule Ello.V3.Schema.NetworkTypes do
  use Absinthe.Schema.Notation

  # Flags
  # Settings
  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
    field :posts_adult_content, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.posts_adult_content}
    end
    field :has_commenting_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_commenting_enabled}
    end
    field :has_reposting_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_reposting_enabled}
    end
    field :has_sharing_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_sharing_enabled}
    end
    field :has_loves_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_loves_enabled}
    end
    field :is_collaborateable, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.is_collaborateable}
    end
    field :is_hireable, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.is_hireable}
    end
    field :avatar, :avatar, resolve: fn(_args, %{source: user}) ->
      {:ok, user.avatar_struct}
    end
    field :cover_image, :cover_image, resolve: fn(_args, %{source: user}) ->
      {:ok, user.cover_image_struct}
    end

    # field :relationship_priority, :string
  end

  object :avatar do
    field :small, :image, resolve: fn(_args, %{source: avatar_struct}) ->
      {:ok, %{version: get_image_version(avatar_struct, "small"), image: avatar_struct}}
    end
    field :regular, :image, resolve: fn(_args, %{source: avatar_struct}) ->
      {:ok, %{version: get_image_version(avatar_struct, "regular"), image: avatar_struct}}
    end
    field :large, :image, resolve: fn(_args, %{source: avatar_struct}) ->
      {:ok, %{version: get_image_version(avatar_struct, "large"), image: avatar_struct}}
    end
    field :original, :image, resolve: fn(_args, %{source: avatar_struct}) ->
      {:ok, %{version: get_image_version(avatar_struct, "original"), image: avatar_struct}}
    end
  end

  object :cover_image do
    field :hdpi, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "hdpi"), image: cover_image_struct}}
    end
    field :ldpi, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "ldpi"), image: cover_image_struct}}
    end
    field :mdpi, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "mdpi"), image: cover_image_struct}}
    end
    field :xhdpi, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "xhdpi"), image: cover_image_struct}}
    end
    field :original, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "original"), image: cover_image_struct}}
    end
    field :optimized, :image, resolve: fn(_args, %{source: cover_image_struct}) ->
      {:ok, %{version: get_image_version(cover_image_struct, "optimized"), image: cover_image_struct}}
    end
  end

  object :image do
    field :metadata, :metadata, resolve: fn(_args, %{source: %{version: version}}) ->
      {:ok, version}
    end
    field :url, :string, resolve: fn(_args, %{source: %{version: version, image: image}, context: context}) ->
      {:ok, image_url(image.path, filename(version, image, context))}
    end
  end

  object :metadata do
    field :width, :integer
    field :height, :integer
    field :size, :integer
    field :type, :integer
  end

  defp get_image_version(image, "original") do
    %{url: image_url(image.path, image.filename), filename: image.filename}
  end
  defp get_image_version(image, size) do
    Enum.find(image.versions, fn(v) -> v.name == size end)
  end

  defp image_url(path, filename) do
    filename
    |> asset_host
    |> URI.merge(path <> "/" <> filename)
    |> URI.to_string
  end

  # content nsfw + no nsfw = pixellated
  defp filename(version,
                %{user: %{settings: %{posts_adult_content: true}}},
                %{assigns: %{allow_nsfw: false}}), do: version.pixellated_filename
  # content nudity + no nudity = pixellated
  defp filename(version,
                %{user: %{settings: %{posts_nudity: true}}},
                %{assigns: %{allow_nudity: false}}), do: version.pixellated_filename
  # _ + _ = normal
  defp filename(version, _, _), do: version.filename

  defp asset_host(filename) do
    asset_host = "https://" <> Application.get_env(:ello_v2, :asset_host)

    if String.contains?(asset_host, "%d") do
      String.replace(asset_host, "%d", asset_host_number(filename))
    else
      asset_host
    end
  end

  defp asset_host_number(filename) do
    :zlib.open
    |> :zlib.crc32(filename)
    |> Integer.mod(3)
    |> Integer.to_string
  end
end
