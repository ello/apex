defmodule Ello.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:categories) do
      add :name, :string
      add :slug, :string
      add :level, :string
      add :order, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
      add :tile_image, :string
      add :tile_image_metadata, :json
      add :allow_in_onboarding, :boolean, default: false
      add :description, :text
      add :is_sponsored, :boolean, default: false
      add :is_creator_type, :boolean, default: false
      add :header, :string
      add :cta_caption, :string
      add :cta_href, :string
      add :uses_page_promotionals, :boolean
    end

    create_if_not_exists unique_index(:categories, [:slug])
    create_if_not_exists index(:categories, [:level])
    create_if_not_exists index(:categories, [:order])
  end
end
