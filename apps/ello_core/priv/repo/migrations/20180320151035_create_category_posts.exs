defmodule Ello.Core.Repo.Migrations.CreateCategoryPosts do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:category_posts) do
      add :status, :string
      add :category_id, :integer
      add :post_id, :integer
      add :submitted_at, :utc_datetime
      add :submitted_by_id, :integer
      add :featured_at, :utc_datetime
      add :featured_by_id, :integer
      add :unfeatured_at, :utc_datetime
      add :unfeatured_by_id, :integer
      add :removed_at, :utc_datetime
      add :removed_by_id, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

    create_if_not_exists unique_index(:category_posts, [:category_id, :post_id])
    create_if_not_exists index(:category_posts, [:category_id])
    create_if_not_exists index(:category_posts, [:post_id])
  end
end
