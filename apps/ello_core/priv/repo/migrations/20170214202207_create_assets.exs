defmodule Ello.Core.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:assets) do
      add :post_id, :integer
      add :user_id, :integer
      add :attachment, :string
      add :attachment_metadata, :json
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
