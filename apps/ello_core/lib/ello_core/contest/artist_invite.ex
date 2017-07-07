defmodule Ello.Core.Contest.ArtistInvite do
  use Ecto.Schema

  schema "artist_invites" do
    field :title, :string
    field :slug, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :header_image, :string
    field :header_image_metadata, :map
    field :logo_image, :string
    field :logo_image_metadata, :map
    field :invite_type, :string
    field :status, :string
    field :opened_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :raw_description, :string
    field :rendered_description, :string
    field :short_description, :string
    field :submission_body_block, :string
    field :guide, {:array, :map}, default: []
    field :selected_tokens, {:array, :string}, default: []

    belongs_to :brand_account, User
  end
end
