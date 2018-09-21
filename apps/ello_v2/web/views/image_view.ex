defmodule Ello.V2.ImageView do
  use Ello.V2.Web, :view

  @moduledoc """
  Serializes an image and image metadata.

  Usage:

      render(Ello.V2.ImageView, :image, [
        image: user.avatar_struct, # An %Ello.Core.Image{} struct
        conn:  conn                # The conn - for determining pixelation.
      ])
  """

  def render("image.json", %{conn: conn, image: image}) do
    image.versions
    |> Enum.reduce(%{}, &render_version(&1, &2, image, conn))
    |> Map.put("original", %{url: image_url(image.path, image.filename)})
  end

  defp render_version(version, results, image, conn) do
    Map.put(results, version.name, %{
      url:      image_url(image.path, filename(version, image, conn)),
      metadata: metadata(version)
    })
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

  defp metadata(%{height: nil, width: nil, size: nil, type: nil}), do: nil
  defp metadata(version) do
    Map.take(version, [:height, :width, :size, :type])
  end

  @doc """
  Return a full URI given an image path and file name.

  Handles domain sharding.
  """
  def image_url(path, nil), do: ""
  def image_url(path, ""), do: ""
  def image_url(path, filename) do
    filename
    |> asset_host
    |> URI.merge(path <> "/" <> filename)
    |> URI.to_string
  end

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
