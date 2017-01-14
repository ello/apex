defmodule Ello.Core.Network.User do
  use Ecto.Schema
  alias Ello.Core.Network.{Relationship, User}

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

    embeds_one :settings, User.Settings
    has_many :relationships, Relationship, foreign_key: :owner_id
    has_many :inverse_relationships, Relationship, foreign_key: :subject_id

    # Used to eager load user's relationship to current user.
    has_one :relationship_to_current_user, Relationship, foreign_key: :subject_id

    # Used to hold user counts retreived from user
    field :loves_count, :integer, virtual: true
    field :posts_count, :integer, virtual: true
    field :following_count, :integer, virtual: true
    field :followers_count, :integer, virtual: true
  end
end