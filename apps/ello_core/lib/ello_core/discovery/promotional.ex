defmodule Ello.Core.Discovery.Promotional do
  use Ecto.Schema
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Network.User

  @type t :: %__MODULE__{}

  schema "promotionals" do
    field :image, :string
    field :image_metadata, :map
    field :image_struct, :map, virtual: true
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :category, Category
    belongs_to :user, User
  end

  @doc """
  Converts image metadata into image_struct
  """
  @spec load_images(promo :: t) :: t
  def load_images(promo) do
    promo
  end
end
