defmodule Ello.Core.Network.User.Settings do
  use Ecto.Schema

  # A required field for all embedded documents, shouldn't be an interop issue
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "settings" do
    field :is_public, :boolean, default: true
    field :is_hireable, :boolean, default: false
    field :is_collaborateable, :boolean, default: false
    field :discoverable, :boolean, default: true

    # NSFW content (porn)
    field :posts_adult_content, :boolean, default: false
    field :views_adult_content, :boolean, default: false

    # Nudity content (artistic nudity)
    field :posts_nudity, :boolean, default: false

    # Enabled features
    field :has_commenting_enabled, :boolean, default: true
    field :has_loves_enabled, :boolean, default: true
    field :has_sharing_enabled, :boolean, default: true
    field :has_reposting_enabled, :boolean, default: true
    field :has_ad_notifications_enabled, :boolean, default: false
    field :has_auto_watch_enabled, :boolean, default: true

    # email notification
    field :notify_of_mentions_via_email, :boolean, default: true
    field :notify_of_new_followers_via_email, :boolean, default: true
    field :notify_of_comments_via_email, :boolean, default: true
    field :notify_of_comments_on_post_watch_via_email, :boolean, default: true
    field :notify_of_loves_via_email, :boolean, default: true
    field :notify_of_invitation_acceptances_via_email, :boolean, default: true
    field :notify_of_reposts_via_email, :boolean, default: true
    field :notify_of_watches_via_email, :boolean, default: true

    # push notifications
    field :notify_of_mentions_via_push, :boolean, default: true
    field :notify_of_new_followers_via_push, :boolean, default: true
    field :notify_of_comments_via_push, :boolean, default: true
    field :notify_of_comments_on_post_watch_via_push, :boolean, default: true
    field :notify_of_loves_via_push, :boolean, default: true
    field :notify_of_invitation_acceptances_via_push, :boolean, default: true
    field :notify_of_reposts_via_push, :boolean, default: true
    field :notify_of_watches_via_push, :boolean, default: true
    field :notify_of_announcements_via_push, :boolean, default: true

    # misc
    field :allows_analytics, :boolean, default: true

    # Product Updates
    field :subscribe_to_users_email_list, :boolean, default: true

    # Knowtify Tops & Tricks
    field :subscribe_to_onboarding_drip, :boolean, default: true

    # Newsletters
    field :subscribe_to_weekly_ello, :boolean, default: true
    field :subscribe_to_daily_ello, :boolean, default: true
  end
end
