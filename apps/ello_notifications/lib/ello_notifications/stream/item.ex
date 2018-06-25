defmodule Ello.Notifications.Stream.Item do
  @valid_subjects ~w(
    Post User Love InvitedUser Watch ArtistInviteSubmission CategoryPost CategoryUser
  )

  @valid_notification_kinds ~w(
    invitation_accepted_post
    new_followed_user_post
    new_follower_post
    post_mention_notification
    comment_mention_notification
    comment_notification
    comment_on_repost_notification
    comment_on_original_post_notification
    love_notification
    love_on_repost_notification
    love_on_original_post_notification
    repost_notification
    watch_notification
    watch_on_repost_notification
    watch_on_original_post_notification
    watch_comment_notification
    approved_artist_invite_submission
    approved_artist_invite_submission_notification_for_followers
    category_post_featured
    category_repost_featured
    category_post_via_repost_featured
    user_added_as_featured_notification
    user_added_as_curator_notification
    user_added_as_moderator_notification
  )

  defstruct [
    :user_id,
    :subject,
    :subject_id,
    :subject_type,
    :kind,
    :created_at,
    :originating_user,
    :originating_user_id
  ]
end
