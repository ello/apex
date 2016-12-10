defmodule Ello.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users) do
      # Currently Used Fields
      add :email, :string
      add :username, :string
      add :name, :string
      add :short_bio, :text
      add :links, :text
      add :location, :string
      add :location_lat, :float
      add :location_long, :float

      add :avatar, :string
      add :avatar_metadata, :json
      add :cover_image, :string,
      add :cover_image_metadata, :json
      add :background_position, :string

      add :is_system_user, :boolean, default: false
      add :is_public, :boolean, default: true
      add :bad_for_seo?, :boolean, default: true
      add :category_ids, {:array, :integer}

      add :created_at, :datetime
      add :updated_at, :datetime

      # Currently Unused Fields
      # t.string   "encrypted_password",             limit: 255, default: "",    null: false
      # t.string   "reset_password_token",           limit: 255
      # t.datetime "reset_password_sent_at"
      # t.datetime "remember_created_at"
      # t.integer  "sign_in_count",                              default: 0,     null: false
      # t.datetime "current_sign_in_at"
      # t.datetime "last_sign_in_at"
      # t.string   "confirmation_token",             limit: 255
      # t.datetime "confirmed_at"
      # t.datetime "confirmation_sent_at"
      # t.string   "unconfirmed_email",              limit: 255
      # t.boolean  "has_experimental_features",                  default: false, null: false
      # t.boolean  "is_staff",                                   default: false, null: false
      # t.boolean  "is_featured",                                default: false
      # t.string   "avatar_tmp",                     limit: 255
      # t.string   "cover_image_tmp",                limit: 255
      # t.integer  "failed_attempts",                            default: 0
      # t.string   "unlock_token",                   limit: 255
      # t.datetime "locked_at"
      # t.datetime "last_bounced_from_sendgrid_at"
      # t.datetime "last_bounced_from_mailchimp_at"
      # t.string   "email_hash",                     limit: 255,                 null: false
      # t.string   "web_onboarding_version",         limit: 255
      # t.integer  "followed_category_ids",                                                   array: true
      # t.string   "locked_reason"
    end
  end
end
