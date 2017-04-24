defmodule Ello.V2.PostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.{Content, Content.Post}
  alias Ello.Search.PostSearch
  alias Ello.V2.PostView

  def show(conn, params) do
    with %Post{} = post <- load_post(conn, params),
         true           <- owned_by_user(post, params) do
      conn
      |> track_post_view(post, stream_kind: "post", stream_id: post.id)
      |> api_render_if_stale(data: post)
    else
      _ -> send_resp(conn, 404, "")
    end
  end

  @doc """
  GET /v2/posts

  Renders a list of relevant results from post search
  """
  def index(conn, %{"terms" => terms}) do
    posts = PostSearch.post_search(%{terms: terms, current_user: current_user(conn), allow_nsfw: conn.assigns[:allow_nsfw], allow_nudity: conn.assigns[:allow_nudity]})
    api_render_if_stale(conn, PostView, "index.json", data: posts)
  end

  defp load_post(conn, %{"id" => id_or_slug}) do
    Content.post(id_or_slug,
      current_user: conn.assigns[:current_user],
      allow_nsfw: conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity]
    )
  end

  defp owned_by_user(post, %{"user_id" => "~" <> username}),
    do: post.author.username == username
  defp owned_by_user(post, %{"user_id" => user_id}),
    do: "#{post.author.id}" == user_id
  defp owned_by_user(_, _), do: true

end
