defmodule Ello.V2.RelatedPostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content
  alias Ello.V2.PostView

  def index(conn, params) do
    {related_to, posts} = fetch_related_posts(conn, params)
    conn
    |> track_post_view(posts, stream_opts(related_to))
    |> api_render(PostView, :index, data: posts)
  end

  defp fetch_related_posts(conn, %{"post_id" => id_or_token}) do
    Content.related_posts(id_or_token, standard_params(conn, %{
      default: %{per_page: 5}
    }))
  end

  defp stream_opts(%{id: id}), do: [stream_kind: "related", stream_id: id]
  defp stream_opts(_), do: [stream_kind: "related"]
end
