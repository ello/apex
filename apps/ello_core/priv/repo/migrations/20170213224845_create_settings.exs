defmodule Ello.Core.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:settings) do
      add :is_public, :boolean, default: true
      add :is_hireable, :boolean, default: false
      add :is_collaborateable, :boolean, default: false
      add :discoverable, :boolean, default: true
      add :posts_adult_content, :boolean, default: false
      add :views_adult_content, :boolean, default: false
      add :posts_nudity, :boolean, default: false
      add :has_commenting_enabled, :boolean, default: true
      add :has_loves_enabled, :boolean, default: true
      add :has_sharing_enabled, :boolean, default: true
      add :has_reposting_enabled, :boolean, default: true
      add :has_ad_notifications_enabled, :boolean, default: false
      add :has_auto_watch_enabled, :boolean, default: true
      add :notify_of_mentions_via_email, :boolean, default: true
      add :notify_of_new_followers_via_email, :boolean, default: true
      add :notify_of_comments_via_email, :boolean, default: true
      add :notify_of_comments_on_post_watch_via_email, :boolean, default: true
      add :notify_of_loves_via_email, :boolean, default: true
      add :notify_of_invitation_acceptances_via_email, :boolean, default: true
      add :notify_of_reposts_via_email, :boolean, default: true
      add :notify_of_watches_via_email, :boolean, default: true
      add :notify_of_mentions_via_push, :boolean, default: true
      add :notify_of_new_followers_via_push, :boolean, default: true
      add :notify_of_comments_via_push, :boolean, default: true
      add :notify_of_comments_on_post_watch_via_push, :boolean, default: true
      add :notify_of_loves_via_push, :boolean, default: true
      add :notify_of_invitation_acceptances_via_push, :boolean, default: true
      add :notify_of_reposts_via_push, :boolean, default: true
      add :notify_of_watches_via_push, :boolean, default: true
      add :notify_of_announcements_via_push, :boolean, default: true
      add :allows_analytics, :boolean, default: true
      add :subscribe_to_users_email_list, :boolean, default: true
      add :subscribe_to_onboarding_drip, :boolean, default: true
      add :subscribe_to_weekly_ello, :boolean, default: true
      add :subscribe_to_daily_ello, :boolean, default: true
    end
  end
end
