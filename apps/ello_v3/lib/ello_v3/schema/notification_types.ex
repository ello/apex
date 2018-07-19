defmodule Ello.V3.Schema.NotificationTypes do
  use Absinthe.Schema.Notation
  alias Ello.Core.{
    Content,
    Network,
    Contest,
    Discovery,
  }
  alias Content.{Post, Love, Watch}
  alias Contest.ArtistInviteSubmission
  alias Discovery.CategoryPost
  alias Network.{CategoryUser, User}

  enum :notification_category do
    value :all
    value :comments
    value :mentions
    value :loves
    value :reposts
    value :relationships
  end

  object :notification_stream do
    field :next, :string
    field :per_page, :integer
    field :is_last_page, :boolean
    field :notifications, list_of(:notification)
  end

  object :notification do
    field :id, :id, resolve: &notification_id/2
    field :kind, :string
    field :subject_id, :id
    field :subject_type, :string
    field :subject, :notification_subject
    field :originating_user, :user
    field :created_at, :string
  end

  union :notification_subject do
    types [:user, :love, :post, :artist_invite_submission, :category_post, :category_user, :watch]
    resolve_type fn
      %User{}, _ -> :user
      %Post{}, _ -> :post
      %Love{}, _ -> :love
      %CategoryUser{}, _ -> :category_user
      %CategoryPost{}, _ -> :category_post
      %ArtistInviteSubmission{}, _ -> :artist_invite_submission
      %Watch{}, _ -> :watch
    end
  end

  defp notification_id(_, %{source: notification}) do
    {:ok, Enum.join([
      notification.kind,
      notification.subject_id,
      notification.created_at,
      notification.originating_user_id,
    ], ":")}
  end
end
