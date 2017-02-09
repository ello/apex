defmodule Ello.Core.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:posts) do
      add :token, :string
      add :seo_title, :string

      add :is_adult_content, :boolean
      add :is_disabled, :boolean
      add :has_nudity, :boolean
      add :is_saleable, :boolean

      add :body, :json
      add :rendered_content, :json
      add :rendered_summary, :json

      add :mentioned_usernames, {:array, :string}, default: []
      add :category_ids, {:array, :integer}, default: []

      add :author_id, :integer
      add :reposted_source_id, :integer
      add :parent_post_id, :integer

      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
    end
  end
end
