defmodule Ello.V2.Manage.ActivityCountController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest

  plug Ello.Auth.RequireUser
  plug Manage.OwnedArtistInvite

  def all(%{assigns: %{artist_invite: inv}} = conn, _) do
    comments = Task.async(Contest, :artist_invite_comment_count, [%{artist_invite: inv}])
    loves = Task.async(Contest, :artist_invite_love_count, [%{artist_invite: inv}])
    reposts = Task.async(Contest, :artist_invite_repost_count, [%{artist_invite: inv}])
    mentions = Task.async(Contest, :artist_invite_mention_count, [%{artist_invite: inv}])
    followers = Task.async(Contest, :artist_invite_follower_count, [%{artist_invite: inv}])

    api_render(conn, artist_invite: inv, data: %{
      comments:  Task.await(comments),
      loves:     Task.await(loves),
      reposts:   Task.await(reposts),
      followers: Task.await(followers),
      mentions:  Task.await(mentions),
    })
  end
end
