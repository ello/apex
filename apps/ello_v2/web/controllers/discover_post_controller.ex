defmodule Ello.V2.DiscoverPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.V2.PostView
  alias Ello.Search.Post.Search

  @recent_stream "all_post_firehose"

  def recent(conn, _params) do
    stream = fetch_stream(conn, @recent_stream)

    conn
    |> track_post_view(stream.posts, stream_kind: "recent")
    |> add_pagination_headers("/discover/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end

  def trending(conn, _params) do
    page = post_search(conn)
    conn
    |> track_post_view(page.results, stream_kind: "trending")
    |> add_pagination_headers("/discover/posts/trending", page)
    |> api_render_if_stale(PostView, "index.json", data: page.results)
  end

  defp fetch_stream(conn, stream) do
    Stream.fetch(standard_params(conn, %{
      keys:         [stream],
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
  end

  defp post_search(conn) do
    Search.post_search(standard_params(conn, %{
      trending:     true,
      within_days:  14,
      allow_nsfw:   false,
    }))
  end
end
