defmodule Ello.Core.Repo.Migrations.CreateLoves do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:loves) do
      add :post_id, :integer
      add :user_id, :integer
      add :deleted, :boolean, default: false
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end

end
