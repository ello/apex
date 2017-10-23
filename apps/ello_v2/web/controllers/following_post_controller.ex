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

  def recent_updated(conn, _params) do
    with {:ok, if_modified_since} <- if_modified_since(conn),
         stream <- fetch_stream(put_in(conn.params["per_page"], "1")),
         %{posts: [%{created_at: last_modified} | _]} <- stream,
         1 <- Timex.compare(last_modified, if_modified_since, :seconds) do
      # New post! send 204
      conn
      |> put_resp_header("last-modified", Timex.format!(last_modified, "{RFC1123}"))
      |> send_resp(:no_content, "")
    else
      # No new content send 304
      _ -> send_resp(conn, :not_modified, "")
    end
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

  def user(%{assigns: %{current_user: %{is_staff: true}}} = conn, %{"slug" => id_or_username}) do
    user = Network.user(%{
      id_or_username: id_or_username,
      current_user: current_user(conn)
    })
    stream = Stream.fetch(standard_params(conn, %{
      keys: ["#{user.id}" | Network.following_ids(user)],
    }))

    conn
    |> add_pagination_headers("/following/user/#{user.id}/posts/recent", stream)
    |> api_render(PostView, :index, data: stream.posts)
  end
  def user(conn, _), do: send_resp(conn, 404, "")

  defp trending_search(conn) do
    Search.post_search(standard_params(conn, %{
      trending:     true,
      following:    true,
      within_days:  60,
      images_only:  (not is_nil(conn.params["images_only"]))
    }))
  end

  defp if_modified_since(conn) do
    case get_req_header(conn, "if-modified-since") do
      [header] -> Timex.parse(header, "{RFC1123}")
      _        -> :not_available
    end
  end
end
