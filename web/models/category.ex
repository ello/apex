defmodule Ello.Category do
  use Ello.Web, :model

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :level, :string
    field :order, :integer
    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime
    field :tile_image, :string
    field :tile_image_metadata, :map
    field :allow_in_onboarding, :boolean, default: false
    field :description, :string
    field :is_sponsored, :boolean, default: false
    field :header, :string
    field :cta_caption, :string
    field :cta_href, :string
    field :uses_page_promotionals, :boolean
  end
end
