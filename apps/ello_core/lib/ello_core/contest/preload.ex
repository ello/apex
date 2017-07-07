defmodule Ello.Core.Contest.Preload do
  alias Ello.Core.{Repo, Network, Contest}
  alias Contest.ArtistInvite

  def artist_invites(nil, _), do: nil
  def artist_invites([], _),  do: []
  def artist_invites(artist_invites, options) do
    artist_invites
    |> include_brand_accounts(options)
  end

  defp include_brand_accounts(artist_invites, options), do:
    Repo.preload(artist_invites, brand_account: &Network.users(%{ids: &1, current_user: options[:current_user]}))
end
