defmodule Ello.V3.Schema.AssetTypes do
  import Ello.V3.Schema.Helpers
  use Absinthe.Schema.Notation

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
