defmodule Ello.Repo.Migrations.CreateRelationship do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:followerships) do
      add :priority, :string

      add :subject_id, :integer
      add :owner_id, :integer

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
