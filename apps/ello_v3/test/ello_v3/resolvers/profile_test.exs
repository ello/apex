defmodule Ello.V3.Resolvers.ProfileTest do
  use Ello.V3.Case

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    archer = Script.insert(:archer,
      web_onboarding_version: "1",
      settings: %{
        allows_analytics: true,
        has_ad_notifications_enabled: true,
        has_announcements_enabled: true,
        has_auto_watch_enabled: true,
        has_reposting_enabled: true,
        has_sharing_enabled: true,
        is_collaborateable: true,
        is_hireable: true,
        is_brand: false,
        notify_of_announcements_via_push: true,
        notify_of_approved_submissions_from_following_via_email: true,
        notify_of_approved_submissions_via_push: true,
        notify_of_featured_category_post_via_email: true,
        notify_of_featured_category_post_via_push: true,
        notify_of_approved_submissions_from_following_via_push: true,
        notify_of_comments_on_post_watch_via_email: true,
        notify_of_comments_on_post_watch_via_push: true,
        notify_of_comments_via_email: true,
        notify_of_comments_via_push: true,
        notify_of_invitation_acceptances_via_email: true,
        notify_of_invitation_acceptances_via_push: true,
        notify_of_loves_via_email: true,
        notify_of_loves_via_push: true,
        notify_of_mentions_via_email: true,
        notify_of_mentions_via_push: true,
        notify_of_new_followers_via_email: true,
        notify_of_new_followers_via_push: true,
        notify_of_reposts_via_email: true,
        notify_of_reposts_via_push: true,
        notify_of_watches_via_email: true,
        notify_of_watches_via_push: true,
        notify_of_what_you_missed_via_email: true,
        subscribe_to_daily_ello: true,
        subscribe_to_onboarding_drip: true,
        subscribe_to_users_email_list: true,
        subscribe_to_weekly_ello: true,
      }
      )
    {:ok, user: archer}
  end

  @query """
  {
    profile {
        name
        username
        email
        location
        formatted_short_bio
        short_bio
        web_onboarding_version
        allows_analytics
        discoverable
        has_ad_notifications_enabled
        has_announcements_enabled
        has_auto_watch_enabled
        has_reposting_enabled
        has_sharing_enabled
        is_collaborateable
        is_hireable
        is_brand
        notify_of_announcements_via_push
        notify_of_approved_submissions_from_following_via_email
        notify_of_approved_submissions_via_push
        notify_of_featured_category_post_via_email
        notify_of_featured_category_post_via_push
        notify_of_approved_submissions_from_following_via_push
        notify_of_comments_on_post_watch_via_email
        notify_of_comments_on_post_watch_via_push
        notify_of_comments_via_email
        notify_of_comments_via_push
        notify_of_invitation_acceptances_via_email
        notify_of_invitation_acceptances_via_push
        notify_of_loves_via_email
        notify_of_loves_via_push
        notify_of_mentions_via_email
        notify_of_mentions_via_push
        notify_of_new_followers_via_email
        notify_of_new_followers_via_push
        notify_of_reposts_via_email
        notify_of_reposts_via_push
        notify_of_watches_via_email
        notify_of_watches_via_push
        notify_of_what_you_missed_via_email
        subscribe_to_daily_ello
        subscribe_to_onboarding_drip
        subscribe_to_users_email_list
        subscribe_to_weekly_ello
      }
  }
  """

  test "Returns all profile properties", %{
    user: user,
  } do
    resp = post_graphql(%{query: @query}, user)
    assert %{"data" => %{"profile" => json}} = json_response(resp)

    assert json["name"]
    assert json["username"]
    assert json["email"]
    assert json["location"]
    assert json["formatted_short_bio"]
    assert json["short_bio"]
    assert json["web_onboarding_version"]
    assert json["allows_analytics"]
    assert json["discoverable"]
    assert json["has_ad_notifications_enabled"]
    assert json["has_announcements_enabled"]
    assert json["has_auto_watch_enabled"]
    assert json["has_reposting_enabled"]
    assert json["has_sharing_enabled"]
    assert json["is_collaborateable"]
    assert json["is_hireable"]
    assert json["is_brand"] == false
    assert json["notify_of_announcements_via_push"]
    assert json["notify_of_approved_submissions_from_following_via_email"]
    assert json["notify_of_approved_submissions_via_push"]
    assert json["notify_of_featured_category_post_via_email"]
    assert json["notify_of_featured_category_post_via_push"]
    assert json["notify_of_approved_submissions_from_following_via_push"]
    assert json["notify_of_comments_on_post_watch_via_email"]
    assert json["notify_of_comments_on_post_watch_via_push"]
    assert json["notify_of_comments_via_email"]
    assert json["notify_of_comments_via_push"]
    assert json["notify_of_invitation_acceptances_via_email"]
    assert json["notify_of_invitation_acceptances_via_push"]
    assert json["notify_of_loves_via_email"]
    assert json["notify_of_loves_via_push"]
    assert json["notify_of_mentions_via_email"]
    assert json["notify_of_mentions_via_push"]
    assert json["notify_of_new_followers_via_email"]
    assert json["notify_of_new_followers_via_push"]
    assert json["notify_of_reposts_via_email"]
    assert json["notify_of_reposts_via_push"]
    assert json["notify_of_watches_via_email"]
    assert json["notify_of_watches_via_push"]
    assert json["notify_of_what_you_missed_via_email"]
    assert json["subscribe_to_daily_ello"]
    assert json["subscribe_to_onboarding_drip"]
    assert json["subscribe_to_users_email_list"]
    assert json["subscribe_to_weekly_ello"]
  end
end
