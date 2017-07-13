defmodule Ello.Core.Contest do
  import Ecto.Query
  alias Ello.Core.{
    Repo,
    Content,
  }
  alias __MODULE__.{
    ArtistInvite,
    ArtistInviteSubmission,
    Preload,
  }

  def artist_invite(%{id_or_slug: id_or_slug, preview: true, current_user: %{is_staff: true}} = options) do
    ArtistInvite
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end
  def artist_invite(%{id_or_slug: id_or_slug, preview: true, current_user: current_user} = options) do
    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user.id or ai.status != "preview")
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end
  def artist_invite(%{id_or_slug: id_or_slug} = options) do
    ArtistInvite
    |> where([ai], ai.status != "preview")
    |> Repo.get_by_id_or_slug(id_or_slug: id_or_slug)
    |> Preload.artist_invites(options)
  end

  def artist_invites(%{page: page, per_page: per_page, preview: true, current_user: %{is_staff: true}} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
  def artist_invites(%{page: page, per_page: per_page, preview: true, current_user: current_user} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> where([ai], ai.brand_account_id == ^current_user.id or ai.status != "preview")
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
  def artist_invites(%{page: page, per_page: per_page} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> where([ai], ai.status != "preview")
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end

  @doc """
  Return artist invite submissions for a given invite.
  """
  # TODO: pagination, refactor
  def artist_invite_submissions(%{
    status:       "submitted",
    invite:       %{brand_account_id: user_id},
    current_user: %{id: user_id}
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "submitted")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{
    status:       "submitted",
    current_user: %{is_staff: true},
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "submitted")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{status: "submitted"}), do: []
  def artist_invite_submissions(%{
    status: "approved",
    invite: %{status: "open"},
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status in ["approved", "selected"])
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{
    status: "approved",
    invite: %{status: "closed"},
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "approved")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{
    status: "selected",
    invite: %{status: "closed"},
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "selected")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{
    status: "selected",
    current_user: %{is_staff: true},
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "selected")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(%{
    status: "selected",
    invite:       %{brand_account_id: user_id},
    current_user: %{id: user_id}
  } = options) do
    ArtistInviteSubmission
    |> for_invite(options)
    |> where([s], s.status == "selected")
    |> Repo.all
    |> Preload.artist_invite_submissions(options)
  end
  def artist_invite_submissions(_), do: []

  defp for_invite(query, %{invite: %{id: id}}) do
    where(query, [s], s.artist_invite_id == ^id)
  end
end
