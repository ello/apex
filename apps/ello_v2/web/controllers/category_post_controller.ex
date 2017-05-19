defmodule Ello.V2.CategoryPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.Search.PostSearch
  alias Ello.V2.PostView
  alias Ello.Core.Discovery

  def recent(conn, params) do
    case Discovery.category_without_includes(params["slug"]) do
      nil -> send_resp(conn, 404, "")
      category ->
        stream = fetch_stream(conn, [category])

        conn
        |> track_post_view(stream.posts, stream_kind: "category", stream_id: category.id)
        |> add_pagination_headers("/categories/#{category.slug}/posts/recent", stream)
        |> api_render(PostView, :index, data: stream.posts)
    end
  end

  def trending(conn, params) do
    case Discovery.category_without_includes(params["slug"]) do
      nil -> send_resp(conn, 404, "")
      category ->
        results = fetch_trending(conn, category)

        conn
        |> track_post_view(results.results, stream_kind: "category_trending", stream_id: category.id)
        |> add_pagination_headers("/categories/#{category.slug}/posts/trending", results)
        |> api_render(PostView, :index, data: results.results)
    end
  end

  def featured(conn, _params) do
    categories = Discovery.primary_categories
    stream = fetch_stream(conn, categories)

    conn
    |> track_post_view(stream.posts, stream_kind: "featured")
    |> add_pagination_headers("/categories/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn, categories) do
    Stream.fetch(standard_params(conn, %{
      keys:         Enum.map(categories, &category_stream_key/1),
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
  end

  defp category_stream_key(%{slug: slug}), do: "categories:v1:#{slug}"

  defp fetch_trending(conn, category) do
    PostSearch.post_search(standard_params(conn, %{
      category:     category.id,
      trending:     true,
      within_days:  60,
      allow_nsfw:   false,
    }))
  end
end
