defmodule Ello.Core.Discovery.Promotional do
  use Ecto.Schema
  alias Ello.Core.Discovery.Category
  alias Ello.Core.Network.User

  schema "promotionals" do
    field :image, :string
    field :image_metadata, :map
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    belongs_to :category, Category
    belongs_to :user, User
  end
end
