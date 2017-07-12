defmodule Ello.Core.Contest do
  import Ecto.Query
  alias Ello.Core.Contest.{ArtistInvite, Preload}
  alias Ello.Core.Repo

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
end
