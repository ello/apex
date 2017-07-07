defmodule Ello.Core.Repo.Migrations.CreateArtistInviteTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:artist_invites) do
      add :title, :string
      add :slug, :string
      add :header_image, :string
      add :header_image_metadata, :json
      add :logo_image, :string
      add :logo_image_metadata, :json
      add :invite_type, :string
      add :status, :string
      add :opened_at, :utc_datetime
      add :closed_at, :utc_datetime
      add :raw_description, :text
      add :rendered_description, :text
      add :short_description, :text
      add :submission_body_block, :string
      add :guide, :json, default: []
      add :selected_tokens, {:array, :string}, default: []
      add :brand_account_id, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
