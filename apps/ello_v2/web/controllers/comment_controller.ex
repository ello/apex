defmodule Ello.V2.CommentController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content
  alias Ello.V2.CommentView

  plug :find_post
  plug :comments_enabled

  def index(conn, _params) do
    comments = find_comments(conn, conn.assigns.post)
    conn
    |> track_post_view(comments, stream_kind: "comment")
    |> add_pagination_headers("/posts/#{conn.assigns.post.id}/comments", comments)
    |> api_render_if_stale(CommentView, "index.json", data: comments)
  end

  defp find_post(conn, _) do
    id_or_token = conn.params["post_id"]
    case Content.post(standard_params(conn, %{id_or_token: id_or_token})) do
      nil  -> halt send_resp(conn, 404, '')
      post -> assign(conn, :post, post)
    end
  end

  defp comments_enabled(conn, _) do
    if conn.assigns[:post].author.settings.has_commenting_enabled do
      conn
    else
      halt send_resp(conn, 404, '')
    end
  end

  defp find_comments(conn, post) do
    Content.comments(standard_params(conn, %{post: post}))
  end
end
