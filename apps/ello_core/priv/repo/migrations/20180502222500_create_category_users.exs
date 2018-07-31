defmodule Ello.Core.Repo.Migrations.CreateCategoryUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:category_users) do
      add :role, :string
      add :user_id, :integer
      add :category_id, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime

      add :featured_at, :utc_datetime
      add :featured_by_id, :integer

      add :curator_at, :utc_datetime
      add :curator_by_id, :integer

      add :moderator_at, :utc_datetime
      add :moderator_by_id, :integer
    end

    create_if_not_exists unique_index(:category_users, [:role, :user_id, :category_id])
    create_if_not_exists index(:category_users, [:user_id])
    create_if_not_exists index(:category_users, [:category_id])
    create_if_not_exists index(:category_users, [:role])
  end
end
