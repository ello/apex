defmodule Ello.Core.Discovery.Promotional.PromotionalImage do
  alias Ello.Core.Image
  alias Ello.Core.Discovery.Promotional

  @spec from_promo(promo :: Promotional.t) :: Image.t
  def from_promo(promo) do
    %Image{
      filename: promo.image,
      path:     "/uploads/promotional/image/#{promo.id}",
      versions: Image.Version.from_metadata(promo.image_metadata, promo.image),
    }
  end
end

