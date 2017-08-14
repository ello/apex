defmodule Ello.Serve.Webapp.SearchController do
  use Ello.Serve.Web, :controller
  alias Ello.Search.User.Search, as: UserSearch
  alias Ello.Search.Post.Search, as: PostSearch

  def index(conn, %{"type" => "users"}) do
    render_html(conn, %{
      title: "Search | Ello",
      robots: "noindex, follow",
      description: "Find creators on Ello creating Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling works.",
      type: "users",
      search: fn -> load_user_search(conn) end
    })
  end

  def index(conn, _) do
    render_html(conn, %{
      title: "Search | Ello",
      robots: "noindex, follow",
      description: "Find work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling.",
      type: "posts",
      search: fn -> load_post_search(conn) end
    })
  end

  defp load_post_search(conn) do
    search = PostSearch.post_search(standard_params(conn, search_params(conn)))
    track(conn, search.results, stream_kind: "search")
    search
  end

  defp load_user_search(conn),
    do: UserSearch.user_search(standard_params(conn, search_params(conn)))

  defp search_params(conn) do
    %{
      terms:        conn.params["terms"] || "",
      current_user: nil,
    }
  end
end
