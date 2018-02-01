defmodule Ello.V3.Schema.Helpers do

  # Gets a json field propery with a string instead of atom name.
  def str_get(_, %{source: source, definition: %{schema_node: %{identifier: name}}}) do
    {:ok, Map.get(source, "#{name}")}
  end

  def resolve_image(_, %{source: image_struct, definition: %{schema_node: %{identifier: name}}}) do
    {:ok, %{version: get_image_version(image_struct, name), image: image_struct}}
  end

  defp get_image_version(image, :original) do
    %{url: image_url(image.path, image.filename), filename: image.filename}
  end
  defp get_image_version(image, size) do
    Enum.find(image.versions, fn(v) -> v.name == to_string(size) end)
  end

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
