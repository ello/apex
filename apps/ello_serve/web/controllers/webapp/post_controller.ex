defmodule Ello.Serve.Webapp.PostController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  alias Content.Post

  def show(conn, params) do
    with %Post{} = post <- load_post(conn, params),
         true           <- owned_by_user(post, params) do
      render_html(conn, post: post)
    else
      _ ->
        if conn.assigns.logged_in_user? do
          render_html(conn)
        else
          send_resp(conn, 404, "")
        end
    end
  end

  defp load_post(conn, %{"token" => token}) do
    post = Content.post(%{
      id_or_token:  "~" <> token,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
    track(conn, post, stream_kind: "post")
    post
  end

  defp owned_by_user(post, %{"username" => username}),
    do: post.author.username == username
end
