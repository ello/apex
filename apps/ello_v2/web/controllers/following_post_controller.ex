defmodule Ello.V2.FollowingPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.Core.{Network}
  alias Ello.V2.PostView
  plug Ello.Auth.RequireUser

  def recent(conn, _params) do
    stream = fetch_stream(conn)

    conn
    |> track_post_view(stream.posts, stream_kind: "following")
    |> add_pagination_headers("/following/posts/recent", stream)
    |> api_render_if_stale(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn) do
    current_user = current_user(conn)
    Stream.fetch(standard_params(conn, %{
      keys: ["#{current_user.id}" | Network.following_ids(current_user)],
    }))
  end

  def trending(conn, _params) do
    results = trending_search(conn)

    conn
    |> track_post_view(results.results, stream_kind: "following_trending")
    |> add_pagination_headers("/following/posts/trending", results)
    |> api_render_if_stale(PostView, :index, data: results.results)
  end

  defp trending_search(conn) do
    Search.post_search(standard_params(conn, %{
      trending:     true,
      following:    true,
      within_days:  60,
      images_only:  (not is_nil(conn.params["images_only"]))
    }))
  end
end
