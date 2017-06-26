defmodule Ello.Serve.Webapp.PostController do
  use Ello.Serve.Web, :controller
  alias Ello.Core.Content
  alias Content.Post

  def show(conn, params) do
    with %Post{} = post <- load_post(params),
         true           <- owned_by_user(post, params) do
      render_html(conn, post: post)
    else
      _ -> send_resp(conn, 404, "")
    end
  end

  defp load_post(%{"token" => token}) do
    Content.post(%{
      id_or_token:  "~" <> token,
      current_user: nil,
      allow_nsfw:   true,
      allow_nudity: true,
    })
  end

  defp owned_by_user(post, %{"username" => username}),
    do: post.author.username == username
end
