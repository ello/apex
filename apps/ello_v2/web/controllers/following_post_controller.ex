defmodule Ello.V2.FollowingPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.Search.PostSearch
  alias Ello.Core.{Network}
  alias Ello.V2.PostView
  plug Ello.Auth.RequireUser

  def recent(conn, params) do
    stream = fetch_stream(conn, params)

    conn
    |> track_post_view(stream.posts, stream_kind: "following")
    |> add_pagination_headers("/following/posts/recent", stream)
    |> api_render_if_stale(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn, params) do
    current_user = current_user(conn)
    Stream.fetch(
      keys:         ["#{current_user.id}" | Network.following_ids(current_user)],
      before:       params["before"],
      per_page:     String.to_integer(params["per_page"] || "25"),
      current_user: current_user,
      allow_nsfw:   conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
    )
  end

  def trending(conn, params) do
    results = trending_search(conn, params)

    conn
    |> track_post_view(results.results, stream_kind: "following_trending")
    |> add_pagination_headers("/following/posts/trending", results)
    |> api_render_if_stale(PostView, :index, data: results.results)
  end

  defp trending_search(conn, params) do
    PostSearch.post_search(%{
      trending:     true,
      following:    true,
      within_days:  14,
      current_user: current_user(conn),
      allow_nsfw:   conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      page:         params["page"],
      per_page:     params["per_page"]
    })
  end
end
