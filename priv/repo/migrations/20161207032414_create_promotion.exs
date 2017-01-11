defmodule Ello.Repo.Migrations.CreatePromotionals do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:promotionals) do
      add :tile_image, :string
      add :tile_image_metadata, :json
      add :created_at, :datetime
      add :updated_at, :datetime

      add :category_id, :integer
      add :user_id, :integer
    end

    create_if_not_exists index(:promotionals, [:category_id])
  end
end
