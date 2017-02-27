defmodule Ello.Core.Image do
  defstruct [user: nil, filename: nil, path: nil, versions: []]

  @type t :: %__MODULE__{}

  defmodule Version do
    defstruct [name: nil, width: nil, height: nil, size: nil, type: nil, filename: nil, pixellated_filename: nil]

    def from_metadata(metadata, original_filename) do
      Enum.map metadata, fn({name, properties}) ->
        %__MODULE__{
          name: name,
          width: properties["width"],
          height: properties["height"],
          size: properties["size"],
          type: properties["type"],
          filename: properties["filename"] || filename(original_filename, name, properties["type"]),
          pixellated_filename: properties["filename"] || filename(original_filename, name <> "-pixellated", properties["type"]),
        }
      end
    end

    defp filename(original_filename, version_name, type) do
      version_name = String.replace(version_name, "_", "-")
      ext          = extension(type)
      hash         = hash_name(original_filename)
      Enum.join(["ello", version_name, hash], "-") <> ext
    end

    # MD5 of value stored in db, minus the file extension
    defp hash_name(name) do
      ~r/(.*)\.([^.]*)$/
      |> Regex.run(name)
      |> Enum.at(1)
      |> :erlang.md5
      |> Base.encode16(case: :lower)
      |> String.slice(0..7)
    end

    defp extension("image/png"), do: ".png"
    defp extension("image/jpeg"), do: ".jpg"
    defp extension("image/gif"), do: ".gif"
    defp extension(_), do: ".png"
  end
end
