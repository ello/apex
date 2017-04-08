defmodule Ello.V2.CategoryPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.V2.PostView

  def recent(conn, params) do
    case Ello.Core.Discovery.category_without_includes(params["slug"]) do
      nil -> send_resp(conn, 404, "")
      category ->
        stream = fetch_stream(conn, [category], params)

        conn
        |> track_post_view(stream.posts, stream_kind: "category")
        |> add_pagination_headers("/categories/#{category.slug}/posts/recent", stream)
        |> api_render_if_stale(PostView, :index, data: stream.posts)
    end
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
end
