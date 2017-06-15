defmodule Ello.Serve.Webapp.DiscoverPostController do
  use Ello.Serve.Web, :controller

  # TODO: fallback content
  def trending(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Explore trending work on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling."
    })
  end

  def recent(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Discover recent work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, Writing, Music, Textile, Skate and Cycling.",
    })
  end

  def featured(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about."
    })
  end
end
