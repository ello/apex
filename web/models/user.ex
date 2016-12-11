defmodule Ello.User do
  use Ello.Web, :model

  schema "users" do
    field :email, :string
    field :email_hash, :string
    field :username, :string
    field :name, :string
    field :short_bio, :string
    field :links, :string
    field :location, :string
    field :location_lat, :float
    field :location_long, :float

    field :avatar, :string
    field :avatar_metadata, :map
    field :cover_image, :string
    field :cover_image_metadata, :map
    field :background_position, :string

    field :is_system_user, :boolean, default: false
    field :is_public, :boolean, default: true
    field :bad_for_seo?, :boolean, default: true
    field :category_ids, {:array, :integer}, default: []

    field :created_at, Ecto.DateTime
    field :updated_at, Ecto.DateTime

    embeds_one :settings, Ello.User.Settings
  end
end
