defmodule Ello.V2.PromotionalView do
  use Ello.V2.Web, :view
  alias Ello.V2.ImageView

  @doc "Render a single promotional as included in other reponses"
  def render("promotional.json", %{promotional: promo} = opts) do
    render_self(promo, __MODULE__, opts)
  end

  def attributes, do: []
  def computed_attributes, do: [
    :image,
    :category_id,
    :user_id
  ]

  def image(promo, conn),
    do: render(ImageView, "image.json", image: promo.image_struct, conn: conn)

  def category_id(%{category_id: cat_id}, _), do: "#{cat_id}"

  def user_id(%{user_id: user_id}, _), do: "#{user_id}"

  def links(promo, _) do
    %{
      user: %{
        href: "/api/v2/users/#{promo.user_id}",
        id:   "#{promo.user_id}",
        type: "users",
      },
    }
  end
end
