defmodule Ello.Core.Repo.Migrations.CreateArtistInviteTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:artist_invites) do
      add :title, :string
      add :meta_title, :string
      add :slug, :string
      add :header_image, :string
      add :header_image_metadata, :json
      add :logo_image, :string
      add :logo_image_metadata, :json
      add :og_image, :string
      add :og_image_metadata, :json
      add :invite_type, :string
      add :redirect_url, :string
      add :status, :string
      add :opened_at, :utc_datetime
      add :closed_at, :utc_datetime
      add :raw_description, :text
      add :rendered_description, :text
      add :raw_short_description, :text
      add :meta_description, :string
      add :rendered_short_description, :text
      add :submission_body_block, :string
      add :guide, :json
      add :brand_account_id, :integer
      add :custom_stats, :json
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
