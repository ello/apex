defmodule Ello.Core.Repo.Migrations.CreateCategoryUsers do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:category_users) do
      add :role, :string
      add :user_id, :integer
      add :category_id, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

    create_if_not_exists unique_index(:category_users, [:role, :user_id, :category_id])
    create_if_not_exists index(:category_users, [:user_id])
    create_if_not_exists index(:category_users, [:category_id])
    create_if_not_exists index(:category_users, [:role])
  end
end
