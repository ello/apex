defmodule Ello.Core.ImageTest do
  use Ello.Core.Case
  alias Ello.Core.Image

  test "Version.from_metadata/2 - parses metadata" do
    metadata = %{
      "large" => %{
        "size" => 220_669,
        "type" => "image/png",
        "width" => 360,
        "height" => 360
      },
      "regular" => %{
        "size" => 36_629,
        "type" => "image/png",
        "width" => 120,
        "height" => 120
      },
      "small" => %{
        "size" => 17_753,
        "type" => "image/png",
        "width" => 60,
        "height" => 60
      }
    }
    name = "ello-2274bdfe-57d8-4499-ba67-a7c003d5a962.png"

    assert [%Image.Version{}, %Image.Version{}, %Image.Version{}] = Image.Version.from_metadata(metadata, name)
    assert %Image.Version{
      name: "large",
      width: 360,
      height: 360,
      size: 220_669,
      type: "image/png",
      filename: "ello-large-fad52e18.png",
      pixellated_filename: "ello-large-pixellated-fad52e18.png",
    } = hd(Image.Version.from_metadata(metadata, name))
  end

  test "Version.from_metadata/2 - parses metadata when there is a period in original filename" do
    metadata = %{
      "large" => %{
        "size" => 220_669,
        "type" => "image/png",
        "width" => 360,
        "height" => 360
      },
      "regular" => %{
        "size" => 36_629,
        "type" => "image/png",
        "width" => 120,
        "height" => 120
      },
      "small" => %{
        "size" => 17_753,
        "type" => "image/png",
        "width" => 60,
        "height" => 60
      }
    }
    name = "BergerFohr.Mashup.2.Avatar.png"

    assert [%Image.Version{}, %Image.Version{}, %Image.Version{}] = Image.Version.from_metadata(metadata, name)
    assert %Image.Version{
      name: "large",
      width: 360,
      height: 360,
      size: 220_669,
      type: "image/png",
      filename: "ello-large-a56b875a.png",
      pixellated_filename: "ello-large-pixellated-a56b875a.png",
    } = hd(Image.Version.from_metadata(metadata, name))
  end

end
