defmodule Ello.V2.PostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.{Content, Content.Post}
  alias Ello.Search.Post.Search
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
  def index(conn, params) do
    page = post_search(conn, params)
    conn
    |> track_post_view(page.results, stream_kind: "search")
    |> add_pagination_headers("/posts", page)
    |> api_render_if_stale(PostView, "index.json", data: page.results)
  end

  defp load_post(conn, %{"id" => id_or_token}) do
    Content.post(standard_params(conn, %{
      id_or_token: id_or_token,
    }))
  end

  defp post_search(conn, params) do
    Search.post_search(standard_params(conn, %{
      terms: params["terms"],
    }))
  end

  defp owned_by_user(post, %{"user_id" => "~" <> username}),
    do: post.author.username == username
  defp owned_by_user(post, %{"user_id" => user_id}),
    do: "#{post.author.id}" == user_id
  defp owned_by_user(_, _), do: true

end
