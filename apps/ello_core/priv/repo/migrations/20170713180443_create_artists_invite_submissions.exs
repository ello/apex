defmodule Ello.Core.Repo.Migrations.CreateArtistsInviteSubmissions do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:artist_invite_submissions) do
      add :status, :string
      add :post_id, :integer
      add :artist_invite_id, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
