defmodule Ello.V2.CategoryPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.V2.PostView
  alias Ello.Core.{Discovery, Contest}
  alias Discovery.Category
  alias Contest.ArtistInvite

  def recent(conn, params) do
    case fetch_category(conn, params) do
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
    case fetch_category(conn, params) do
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
    categories = Task.async(Discovery, :categories, [standard_params(conn, %{
      primary:      true,
      images:       false,
      promotionals: false,
    })])

    invites = Task.async(Contest, :artist_invites, [standard_params(conn, %{
      for_discovery: true,
    })])

    stream = fetch_stream(conn, Task.await(categories) ++ Task.await(invites))

    conn
    |> track_post_view(stream.posts, stream_kind: "featured")
    |> add_pagination_headers("/categories/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn, models) do
    Stream.fetch(standard_params(conn, %{
      keys:         Enum.map(models, &stream_key/1),
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
  end

  defp stream_key(%Category{roshi_slug: slug}), do: "categories:v1:#{slug}"
  defp stream_key(%ArtistInvite{id: id}), do: "artist_invite:v1:#{id}"

  defp fetch_trending(conn, category) do
    Search.post_search(standard_params(conn, %{
      category:     category.id,
      trending:     true,
      within_days:  60,
      allow_nsfw:   false,
      images_only:  (not is_nil(conn.params["images_only"])),
    }))
  end

  def fetch_category(conn, params) do
    Discovery.category(standard_params(conn, %{
      id_or_slug: params["slug"],
      images:     false,
    }))
  end
end
