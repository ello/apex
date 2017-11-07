defmodule Ello.Core.Contest.ArtistInvite do
  use Ecto.Schema
  alias Ello.Core.Network.User
  alias __MODULE__.{HeaderImage, LogoImage, OGImage}

  schema "artist_invites" do
    field :title, :string
    field :meta_title, :string
    field :slug, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    field :header_image_struct, :map, virtual: true
    field :header_image, :string
    field :header_image_metadata, :map
    field :logo_image_struct, :map, virtual: true
    field :logo_image, :string
    field :logo_image_metadata, :map
    field :og_image, :string
    field :og_image_metadata, :map

    field :invite_type, :string
    field :status, :string, default: "preview"
    field :opened_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :raw_description, :string
    field :rendered_description, :string
    field :raw_short_description, :string
    field :rendered_short_description, :string
    field :meta_description, :string
    field :submission_body_block, :string
    field :guide, {:array, :map}, default: []
    field :custom_stats, {:array, :map}, default: []

    belongs_to :brand_account, User
  end

  def load_images(artist_invite) do
    artist_invite
    |> Map.put(:header_image_struct, HeaderImage.from_artist_invite(artist_invite))
    |> Map.put(:logo_image_struct, LogoImage.from_artist_invite(artist_invite))
    |> Map.put(:og_image_struct, OGImage.from_artist_invite(artist_invite))
  end

  def status(%{status: "open", closed_at: nil}), do: "open"
  def status(%{status: "open", opened_at: nil}), do: "upcoming"
  def status(%{status: "open"} = invite) do
    now    = DateTime.utc_now |> DateTime.to_unix
    open   = DateTime.to_unix(invite.opened_at)
    closed = DateTime.to_unix(invite.closed_at)
    cond do
      now < open   -> "upcoming"
      now > closed -> "selecting"
      true         -> "open"
    end
  end
  def status(%{status: status}), do: status
end
