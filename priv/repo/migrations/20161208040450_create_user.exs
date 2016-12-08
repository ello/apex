defmodule Ello.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users) do
      add :email, :string
      add :username, :string
      add :created_at, :datetime
      add :updated_at, :datetime
    end
  end
end
