defmodule Ello.V2.ArtistInviteSubmissionController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Contest
  alias Ello.V2.{
    ArtistInviteSubmissionView,
    PostView,
  }
  plug :find_invite

  def index(%{assigns: %{invite: invite}} = conn, _params) do
    subs = load_submissions(conn, invite)
    conn
    |> track_post_view(subs, stream_kind: "artist_invite_submissions", stream_id: invite.id)
    |> add_pagination_headers("/artist_invites/#{invite.id}/submissions", subs)
    |> api_render_if_stale(ArtistInviteSubmissionView, :index, data: subs)
  end

  def posts(%{assigns: %{invite: invite}} = conn, _params) do
    posts = load_submission_posts(conn, invite)
    conn
    |> track_post_view(posts, stream_kind: "artist_invite_submissions", stream_id: invite.id)
    |> add_pagination_headers("/artist_invites/#{invite.id}/submission_posts", posts)
    |> api_render_if_stale(PostView, :index, data: posts)
  end

  defp find_invite(conn, _) do
    case load_invite(conn) do
      nil    -> halt send_resp(conn, 404, "")
      invite -> assign(conn, :invite, invite)
    end
  end

  defp load_invite(conn) do
    Contest.artist_invite(standard_params(conn, %{
      id_or_slug: conn.params["artist_invite_id"],
    }))
  end

  defp load_submissions(conn, invite) do
    Contest.artist_invite_submissions(standard_params(conn, %{
      invite:      invite,
      status:      conn.params["status"] || "approved",
      images_only: (not is_nil(conn.params["images_only"])),
    }))
  end

  defp load_submission_posts(conn, invite) do
    case load_submissions(conn, invite) do
      []   -> []
      subs -> Enum.map(subs, &(&1.post))
    end
  end
end
