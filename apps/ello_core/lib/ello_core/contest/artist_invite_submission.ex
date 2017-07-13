defmodule Ello.Core.Contest.ArtistInviteSubmission do
  use Ecto.Schema
  alias Ello.Core.Content.Post
  alias Ello.Core.Contest.ArtistInvite

  schema "artist_invite_submissions" do
    field :status, :string
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime

    belongs_to :post, Post
    belongs_to :artist_invite, ArtistInvite
  end
end
