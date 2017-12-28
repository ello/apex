defmodule Ello.Core.Repo.Migrations.CreateFlags do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:flags) do
      add :subject_id, :integer
      add :subject_type, :string
      add :kind, :string
      add :verified, :boolean

      add :reporting_user_id, :integer
      add :subject_user_id, :integer

      add :resolved_at, :utc_datetime
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end

  end
end
