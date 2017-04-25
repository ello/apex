defmodule Ello.V2.DiscoverPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.V2.PostView
  alias Ello.Search.PostSearch

  @recent_stream "all_post_firehose"

  def recent(conn, params) do
    stream = fetch_stream(conn, @recent_stream, params)

    conn
    |> track_post_view(stream.posts, stream_kind: "recent")
    |> add_pagination_headers("/discover/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end

  def trending(conn, params) do
    page = post_search(conn, params)
    conn
    |> track_post_view(page.results, stream_kind: "trending")
    |> add_pagination_headers("/discover/posts/trending", page)
    |> api_render_if_stale(PostView, "index.json", data: page.results)
  end

  defp fetch_stream(conn, stream, params) do
    current_user = current_user(conn)
    Stream.fetch(
      keys:         [stream],
      before:       params["before"],
      per_page:     String.to_integer(params["per_page"] || "25"),
      current_user: current_user,
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
      allow_nudity: conn.assigns[:allow_nudity],
    )
  end

  defp post_search(conn, params) do
    PostSearch.post_search(%{
      trending:     true,
      current_user: current_user(conn),
      allow_nsfw:   conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      page:         params["page"],
      per_page:     params["per_page"]
    })
  end
end
