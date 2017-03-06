defmodule Ello.V2.RelatedPostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content
  alias Ello.V2.PostView

  def index(conn, params) do
    {related_to, posts} = fetch_related_posts(conn, params)
    conn
    |> track_post_view(posts, stream_kind: "related", stream_id: related_to.id)
    |> api_render(PostView, :index, data: posts)
  end

  defp fetch_related_posts(conn, %{"post_id" => id_or_token} = params) do
    Content.related_posts(id_or_token, [
      current_user: current_user(conn),
      allow_nsfw:   conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      per_page:     params["per_page"] || 5,
    ])
  end
end
