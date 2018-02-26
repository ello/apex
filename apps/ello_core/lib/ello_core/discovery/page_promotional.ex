defmodule Ello.Core.Discovery.PagePromotional do
  use Ecto.Schema
  alias Ello.Core.Network.User
  alias Ello.Core.Discovery.PagePromotional.PromotionalImage

  @type t :: %__MODULE__{}

  schema "page_promotionals" do
    field :header, :string
    field :subheader, :string
    field :cta_href, :string
    field :cta_caption, :string
    field :is_logged_in, :boolean
    field :is_artist_invite, :boolean
    field :is_editorial, :boolean
    field :is_authentication, :boolean
    field :image, :string
    field :image_metadata, :map
    field :image_struct, :map, virtual: true
    field :post_token, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :user, User
  end

  @doc """
  Converts image metadata into image_struct
  """
  @spec load_images(promo :: t) :: t
  def load_images(promo) do
    Map.put(promo, :image_struct, PromotionalImage.from_promo(promo))
  end

  defmodule PromotionalImage do
    alias Ello.Core.Image

    def from_promo(promo) do
      %Image{
        filename: promo.image,
        path:     "/uploads/promotional/image/#{promo.id}",
        versions: Image.Version.from_metadata(promo.image_metadata, promo.image),
      }
    end
  end
end
