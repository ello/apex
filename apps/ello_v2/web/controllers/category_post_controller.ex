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
        stream = fetch_stream(conn, [category], params)

        conn
        |> track_post_view(stream.posts, stream_kind: stream_kind(conn), stream_id: category.id)
        |> add_pagination_headers("/categories/#{category.slug}/posts/recent", stream)
        |> api_render(PostView, :index, data: stream.posts)
    end
  end

  def trending(conn, params) do
    case Discovery.category_without_includes(params["slug"]) do
      nil -> send_resp(conn, 404, "")
      category ->
        results = fetch_trending(conn, category, params)

        conn
        |> track_post_view(results.results, stream_kind: "category_trending", stream_id: category.id)
        |> add_pagination_headers("/categories/#{category.slug}/posts/trending", results)
        |> api_render(PostView, :index, data: results.results)
    end
  end

  def featured(conn, params) do
    categories = Discovery.primary_categories
    stream = fetch_stream(conn, categories, params)

    conn
    |> track_post_view(stream.posts, stream_kind: stream_kind(conn))
    |> add_pagination_headers("/categories/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn, categories, params) do
    current_user = current_user(conn)
    Stream.fetch(
      keys:         Enum.map(categories, &category_stream_key/1),
      before:       params["before"],
      per_page:     String.to_integer(params["per_page"] || "25"),
      current_user: current_user,
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
      allow_nudity: conn.assigns[:allow_nudity],
    )
  end

  defp category_stream_key(%{slug: slug}), do: "categories:v1:#{slug}"

  defp stream_kind(conn) do
    case {action_name(conn), conn.params["stream_source"]} do
      {:featured, nil}    -> "featured"
      {:recent, nil}      -> "category"
      {:featured, source} -> "featured_" <> source
      {:recent, source}   -> "category_" <> source
    end
  end

  defp fetch_trending(conn, category, params) do
    current_user = current_user(conn)
    PostSearch.post_search(%{
      category:     category.id,
      trending:     true,
      per_page:     params["per_page"] || "25",
      page:         params["page"],
      current_user: current_user,
      allow_nudity: conn.assigns[:allow_nudity],
      allow_nsfw:   conn.assigns[:allow_nsfw],
    })
  end
end
