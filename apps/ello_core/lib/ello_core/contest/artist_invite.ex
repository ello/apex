defmodule Ello.Core.Contest.ArtistInvite do
  use Ecto.Schema
  alias Ello.Core.Network.User
  alias __MODULE__.{HeaderImage, LogoImage}

  schema "artist_invites" do
    field :title, :string
    field :slug, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    field :header_image_struct, :map, virtual: true
    field :header_image, :string
    field :header_image_metadata, :map
    field :logo_image_struct, :map, virtual: true
    field :logo_image, :string
    field :logo_image_metadata, :map

    field :invite_type, :string
    field :status, :string, default: "preview"
    field :opened_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :raw_description, :string
    field :rendered_description, :string
    field :raw_short_description, :string
    field :rendered_short_description, :string
    field :submission_body_block, :string
    field :guide, {:array, :map}, default: []
    field :selected_tokens, {:array, :string}, default: []

    belongs_to :brand_account, User
  end

  def load_images(artist_invite) do
    artist_invite
    |> Map.put(:header_image_struct, HeaderImage.from_artist_invite(artist_invite))
    |> Map.put(:logo_image_struct, LogoImage.from_artist_invite(artist_invite))
  end
end
