defmodule Ello.V2.AssetView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    ImageView,
  }

  def render("asset.json", %{asset: asset} = conn) do
    %{
      id: "#{asset.id}",
      attachment: render(ImageView, "image.json", conn: conn, image: asset.attachment_struct),
    }
  end

end
