defmodule Ello.V2.RelatedPostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content
  alias Ello.V2.PostView

  def index(conn, %{"post_id" => id_or_token}) do
    case Content.post(standard_params(conn, %{id_or_token: id_or_token})) do
      nil     -> send_resp(conn, 404, "")
      related ->
        posts = fetch_related_posts(conn, related)
        conn
        |> track_post_view(posts, stream_opts(related))
        |> api_render(PostView, :index, data: posts)
    end
  end

  defp fetch_related_posts(conn, related) do
    Content.posts(standard_params(conn, %{
      related_to: related,
      default:    %{per_page: 5}
    }))
  end

  defp stream_opts(%{id: id}), do: [stream_kind: "related", stream_id: id]
  defp stream_opts(_), do: [stream_kind: "related"]
end
