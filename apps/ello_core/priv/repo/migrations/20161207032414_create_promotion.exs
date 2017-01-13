defmodule Ello.Repo.Migrations.CreatePromotionals do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:promotionals) do
      add :image, :string
      add :image_metadata, :json
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime

      add :category_id, :integer
      add :user_id, :integer
    end

    create_if_not_exists index(:promotionals, [:category_id])
  end
end
