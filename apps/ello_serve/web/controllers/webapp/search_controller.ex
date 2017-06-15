defmodule Ello.Serve.Webapp.SearchController do
  use Ello.Serve.Web, :controller

  def index(conn, %{"type" => "users"}) do
    render_html(conn, %{
      title: "Search | Ello",
      robots: "noindex, follow",
      description: "Find creators on Ello creating Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling works.",
    })
  end

  def index(conn, _) do
    render_html(conn, %{
      title: "Search | Ello",
      robots: "noindex, follow",
      description: "Find work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling.",
    })
  end
end
