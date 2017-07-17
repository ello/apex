defmodule Ello.Core.Contest.Preload do
  alias Ello.Core.{
    Repo,
    Network,
    Contest,
    Content,
  }
  alias Contest.ArtistInvite

  def artist_invites(nil, _), do: nil
  def artist_invites([], _),  do: []
  def artist_invites(artist_invites, options) do
    artist_invites
    |> include_brand_accounts(options)
    |> build_image_structs
  end

  defp include_brand_accounts(artist_invites, options), do:
    Repo.preload(artist_invites, brand_account: &Network.users(%{ids: &1, current_user: options[:current_user]}))

  defp build_image_structs(%ArtistInvite{} = a_inv), do: ArtistInvite.load_images(a_inv)
  defp build_image_structs(artist_invites) do
    Enum.map(artist_invites, &build_image_structs/1)
  end

  def artist_invite_submissions(submissions, options) do
    Repo.preload(submissions, post: &Content.posts(Map.put(options, :ids, &1)))
  end
end
