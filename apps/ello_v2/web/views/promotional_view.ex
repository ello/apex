defmodule Ello.V2.PromotionalView do
  use Ello.V2.Web, :view
  alias Ello.V2.ImageView

  def render("promotional.json", %{promotional: promo, conn: conn}) do
    %{
      id: "#{promo.id}",
      image: render(ImageView, "image.json", image: promo.image_struct, conn: conn),
      category_id: "#{promo.category_id}",
      user_id: "#{promo.user_id}",
      links: %{
        user: %{
          href: "/api/v2/users/#{promo.user_id}",
          id: "#{promo.user_id}",
          type: "users",
        },
      },
    }
  end
end
