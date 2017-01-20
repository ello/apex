defmodule Ello.V2.ImageView do
  use Ello.V2.Web, :view
  alias Ello.Core.{
    Discovery.Category,
    Network.User,
  }

  @moduledoc """
  Serializes an image and image metadata.

  Usage:

      render(Ello.V2.ImageView, :image, [
        model:      model,      # The wrapping struct
        attribute: :tile_image, # The field which stores the image
        conn:      conn         # The connection - for determining pixelation.
      ])
  """

  def render("image.json", %{model: model, attribute: attr}) do
    meta = String.to_atom(Atom.to_string(attr) <> "_metadata")
    do_render(model, Map.get(model, attr), Map.get(model, meta), attr)
  end

  defp do_render(model, nil, _, attr), do: default_for(model, attr)
  defp do_render(model, image, metadata, attr) do
    metadata
    |> Enum.reduce(%{}, &render_version(&1, &2, model, image, attr))
    |> Map.put("original", %{"url" => image_url(model, image, attr)})
  end

  defp render_version({version, meta}, versions, model, image, attr) do
    Map.put(versions, version, %{
      "url"      => image_url(model, image, attr, version, meta["type"]),
      "metadata" => meta,
    })
  end

  defp image_url(model, name, attr, version \\ nil, type \\ nil) do
    filename = filename(name, version, type)

    filename
    |> asset_host
    |> URI.merge(asset_path(model, attr) <> "/" <> filename)
    |> URI.to_string
  end

  def asset_path(model, attr) do
    "/uploads/#{model_folder_name(model)}/#{attr}/#{model.id}"
  end

  def asset_host(filename) do
    asset_host = Application.get_env(:ello_v2, :asset_host)
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

  defp model_folder_name(%{__struct__: module}) do
    module
    |> Atom.to_string
    |> String.split(".")
    |> Enum.reverse
    |> hd
    |> Macro.underscore
  end

  defp filename(name, nil, _), do: name
  defp filename(name, version, type) do
    Enum.join(["ello", String.replace(version, "_", "-"), hash_name(name)], "-") <> extension(type)
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

  @default_avatar_images 47
  @default_cover_images 30
  defp default_for(%Category{}, :tile_image) do
    base_path = "images/fallback/category/tile_image"
    gen_defaults(["original", "large", "regular", "small"], base_path, "png")
  end
  defp default_for(%User{} = u, :avatar) do
    image_id = case rem(u.id, @default_avatar_images) do
      0 -> @default_avatar_images
      other -> other
    end
    base_path = "images/fallback/user/cover_image/#{image_id}"
    gen_defaults(["original", "large", "regular", "small"], base_path, "png")
  end
  defp default_for(%User{} = u, :cover_image) do
    image_id = case rem(u.id, @default_cover_images) do
      0 -> @default_cover_images
      other -> other
    end
    base_path = "images/fallback/user/cover_image/#{image_id}"
    gen_defaults(["original", "large", "regular", "small"], base_path, "jpeg")
  end

  defp gen_defaults(variations, base_path, format) do
    Enum.reduce variations, %{}, fn(variation, json) ->
      Map.put(json, variation, %{
        "url"      => default_url(base_path, variation, format),
        "metadata" => nil,
      })
    end
  end

  defp default_url(path, "original", format) do
    "#{asset_host("")}/#{path}/ello-default.#{format}"
  end
  defp default_url(path, variation, format) do
    "#{asset_host("")}/#{path}/ello-default-#{variation}.#{format}"
  end
end
