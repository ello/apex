defmodule Ello.V2.ImageView do
  use Ello.Web, :view

  @moduledoc """
  Serializes an image and image metadata.

  Usage:

      render(Ello.V2.ImageView, :image, [
        model:      model,      # The wrapping struct
        attribute: :tile_image, # The field which stores the image
        conn:      conn         # The connection - for determining pixelation.
      ])
  """

  # TODO: Actually support pixelation - needs user auth
  # TODO: This could probably be cleaned up with a struct for each version

  def render("image.json", %{model: model, attribute: attr}) do
    meta = String.to_atom(Atom.to_string(attr) <> "_metadata")
    do_render(model, Map.get(model, attr), Map.get(model, meta), attr)
  end

  defp do_render(model, nil, _, attr), do: default_for(model.__struct__, attr)
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
    asset_host
    |> URI.merge(asset_path(model, attr) <> "/" <> filename(name, version, type))
    |> URI.to_string
  end

  #TODO: This should probably be more dynamic
  defp default_for(Ello.Category, :tile_image) do
    %{
      "original" => %{
        "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default.png",
      },
      "large" => %{
        "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-large.png",
        "metadata" => nil,
      },
      "regular" => %{
        "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-regular.png",
        "metadata" => nil,
      },
      "small" => %{
        "url" => "https://assets.ello.co/images/fallback/category/tile_image/ello-default-small.png",
        "metadata" => nil,
      },
    }
  end

  def asset_path(model, attr) do
    "uploads/#{model_folder_name(model)}/#{attr}/#{model.id}"
  end

  # TODO: Make setting
  def asset_host do
    "https://assets.ello.co"
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
end
