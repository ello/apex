defmodule Ello.V2.EditorialPostController do
  use Ello.V2.Web, :controller
  alias Ello.V2.PostView
  alias Ello.Core.Content

  def index(conn, params) do
    posts = posts_by_tokens(conn, params)
    conn
    |> track_post_view(posts, stream_kind: "editorial_curated_posts")
    |> api_render_if_stale(PostView, :index, data: posts)
  end

  defp posts_by_tokens(conn, params) do
    case params["token"] do
      tokens when is_list(tokens) ->
        Content.posts(standard_params(conn, %{
          tokens: params["token"],
        }))
      _ -> []
    end
  end
end
