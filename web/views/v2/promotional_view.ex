defmodule Ello.V2.PromotionalView do
  use Ello.Web, :view
  alias Ello.V2.ImageView

  def render("promotional.json", %{promotional: promo}) do
    %{
      id: "#{promo.id}",
      category_id: "#{promo.category_id}",
      image: render(ImageView, "image.json", model: promo, attribute: :image),
    }
  end
end
