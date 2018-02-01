defmodule Ello.V3.Schema.AssetTypes do
  import Ello.V3.Schema.Helpers
  use Absinthe.Schema.Notation

  object :asset do
    field :id, :id
    field :attachment, :responsive_image_versions
  end

  object :tshirt_image_versions do
    field :small, :image, resolve: &resolve_image/2
    field :regular, :image, resolve: &resolve_image/2
    field :large, :image, resolve: &resolve_image/2
    field :original, :image, resolve: &resolve_image/2
  end

  object :responsive_image_versions do
    field :hdpi, :image, resolve: &resolve_image/2
    field :ldpi, :image, resolve: &resolve_image/2
    field :mdpi, :image, resolve: &resolve_image/2
    field :xhdpi, :image, resolve: &resolve_image/2
    field :original, :image, resolve: &resolve_image/2
    field :optimized, :image, resolve: &resolve_image/2
    field :video, :image, resolve: &resolve_image/2
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
end
