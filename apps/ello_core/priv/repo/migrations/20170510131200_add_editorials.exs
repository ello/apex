defmodule Ello.Core.Repo.Migrations.AddEditorials do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:editorials) do
      add :published_position, :integer
      add :preview_position, :integer
      add :kind, :string
      add :post_id, :integer

      add :content, :json

      add :one_by_one_image, :string
      add :one_by_two_image, :string
      add :two_by_one_image, :string
      add :two_by_two_image, :string
      add :one_by_one_image_metadata, :json
      add :one_by_two_image_metadata, :json
      add :two_by_one_image_metadata, :json
      add :two_by_two_image_metadata, :json

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
