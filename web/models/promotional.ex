defmodule Ello.Promotional do
  use Ello.Web, :model

  schema "promotionals" do
    field :image, :string
    field :image_metadata, :map
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :category, Ello.Category
    #belongs_to :user, Ello.User
  end
end
