defmodule Ello.Notifications.Stream.Item do
  @valid_subjects ~w(
    Post User Love Watch ArtistInviteSubmission CategoryPost CategoryUser
  )

  @valid_kinds ~w(
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
    :originating_user_id,
    errors: [],
  ]

  def as_json(%__MODULE__{} = item) do
    Map.take(item, [:user_id, :subject_id, :subject_type, :kind, :created_at, :originating_user_id])
  end

  def to_json(%__MODULE__{} = item) do
    item
    |> as_json
    |> Jason.encode!
  end

  def validate(%__MODULE__{} = item) do
    item
    |> validate_present(:user_id)
    |> validate_present(:subject_id)
    |> validate_present(:subject_type)
    |> validate_present(:kind)
    |> validate_present(:originating_user_id)
    |> validate_inclusion(:subject_type, @valid_subjects)
    |> validate_inclusion(:kind, @valid_kinds)
  end

  defp validate_present(item, field) do
    case Map.get(item, field) do
      nil -> Map.put(item, :errors, ["#{field} must be present" | item.errors])
      _ -> item
    end
  end

  defp validate_inclusion(item, field, list) do
    with val <- Map.get(item, field),
         true <- val in list do
      item
    else
      _ -> Map.put(item, :errors, ["#{field} is an invalid value" | item.errors])
    end
  end
end
