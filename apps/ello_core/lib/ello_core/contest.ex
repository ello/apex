defmodule Ello.Core.Contest do
  import Ecto.Query
  alias Ello.Core.Contest.{ArtistInvite, Preload}
  alias Ello.Core.Repo

  def artist_invites(%{page: page, per_page: per_page} = options) do
    offset = per_page * (page - 1)

    ArtistInvite
    |> order_by(desc: :created_at)
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all
    |> Preload.artist_invites(options)
  end
end
