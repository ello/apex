defmodule Ello.Core.Contest.Preload do
  alias Ello.Core.{
    Repo,
    Contest,
    Content,
  }
  alias Contest.ArtistInvite

  def artist_invites(nil, _), do: nil
  def artist_invites([], _),  do: []
  def artist_invites(artist_invites, _) do
    artist_invites
    |> build_image_structs
  end

  defp build_image_structs(%ArtistInvite{} = a_inv), do: ArtistInvite.load_images(a_inv)
  defp build_image_structs(artist_invites) do
    Enum.map(artist_invites, &build_image_structs/1)
  end

  @default_artist_invite_submission_preloads %{
    posts: %{
      assets: %{},
      current_user_state: %{},
      categories: %{},
      artist_invite_submission: %{artist_invite: %{}},
      author: %{current_user_state: %{}, user_stats: %{}, categories: %{}},
      post_stats: %{},
      reposted_source: %{}
    }
  }

  def artist_invite_submissions(submissions, %{preloads: preloads} = options) do
    submissions
    |> preload_posts(%{options | preloads: preloads[:post]})
  end
  def artist_invite_submissions(s, options) do
    artist_invite_submissions(s, %{options | preloads: @default_artist_invite_submission_preloads})
  end

  defp preload_posts(submissions, %{preloads: nil}), do: submissions
  defp preload_posts(submissions, options) do
    Repo.preload(submissions, post: &Content.posts(Map.put(options, :ids, &1)))
  end
end
