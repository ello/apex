defmodule Ello.V2.FollowingPostController do
  use Ello.V2.Web, :controller
  alias Ello.Stream
  alias Ello.Core.{Network}
  alias Ello.V2.PostView
  plug Ello.Auth.RequireUser

  def index(conn, params) do
    stream = fetch_stream(conn, params)

    conn
    |> track_post_view(stream.posts, stream_kind: "following")
    |> add_page_headers(stream)
    |> api_render_if_stale(PostView, :index, data: stream.posts)
  end

  defp fetch_stream(conn, params) do
    user_ids = Network.following_ids(current_user(conn))

    before = params["before"]
    per_page = String.to_integer(params["per_page"] || "25")
    Stream.fetch(keys: user_ids, before: before, per_page: per_page)
  end

  defp add_page_headers(conn, %{per_page: per_page, before: before}) do
    put_resp_header(conn, "link", "<https://#{webapp_host()}/following/posts/recent?before=#{before}&per_page=#{per_page}>; rel=\"next\"")
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end

end
