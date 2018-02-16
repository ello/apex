defmodule Ello.Core.Repo.Migrations.CreatePagePromotionals do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:page_promotionals) do
      add :header, :string
      add :subheader, :string
      add :cta_href, :string
      add :cta_caption, :string
      add :is_logged_in, :boolean
      add :is_artist_invite, :boolean
      add :is_editorial, :boolean
      add :image, :string
      add :image_metadata, :json

      add :post_token, :string
      add :user_id, :integer

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
