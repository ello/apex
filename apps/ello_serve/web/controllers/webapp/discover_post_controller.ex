defmodule Ello.Serve.Webapp.DiscoverPostController do
  use Ello.Serve.Web, :controller
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.Core.Discovery

  def trending(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Explore trending work on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, 3D, Writing, Music, Textile, Skate and Cycling.",
      categories: fn -> categories(conn) end,
      posts: fn -> trending_posts(conn) end,
    })
  end

  def recent(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Discover recent work from creators on Ello in Art, Fashion, Photography, Design, Architecture, Illustration, GIFs, Writing, Music, Textile, Skate and Cycling.",
      categories: fn -> categories(conn) end,
      posts: fn -> recent_posts(conn) end,
    })
  end

  def featured(conn, _) do
    render_html(conn, %{
      title: "Ello | The Creators Network",
      description: "Welcome to the Creators Network. Ello is a community to discover, discuss, publish, share and promote the things you are passionate about.",
      categories: fn -> categories(conn) end,
      posts: fn -> featured_posts(conn) end,
    })
  end

  def category(conn, params) do
    case fetch_category(conn, params) do
      nil -> send_resp(conn, 404, "")
      cat ->
        render_html(conn, %{
          categories: fn -> categories(conn) end,
          posts:      fn -> category_posts(conn, cat) end,
        })
    end
  end

  defp trending_posts(conn) do
    search = Search.post_search(standard_params(conn, %{
      trending:     true,
      within_days:  14,
      allow_nsfw:   false,
      images_only:  false,
    }))
    track(conn, search.results, stream_kind: "trending")
    search
  end

  defp featured_posts(conn) do
    categories = Discovery.categories(standard_params(conn, %{
      primary:      true,
      images:       false,
      promotionals: false,
    }))

    stream = Stream.fetch(standard_params(conn, %{
      keys:         Enum.map(categories, &category_stream_key/1),
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
    track(conn, stream.posts, stream_kind: "featured")
    stream
  end

  defp category_posts(conn, category) do
    stream = Stream.fetch(standard_params(conn, %{
      keys:         [category_stream_key(category)],
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
    track(conn, stream.posts, stream_kind: "category")
    stream
  end

  defp category_stream_key(%{roshi_slug: slug}), do: "categories:v1:#{slug}"

  @recent_stream "all_post_firehose"
  defp recent_posts(conn) do
    stream = Stream.fetch(standard_params(conn, %{
      keys:         [@recent_stream],
      allow_nsfw:   true, # No NSFW in categories, reduces slop.
    }))
    track(conn, stream.posts, stream_kind: "recent")
    stream
  end

  defp categories(conn) do
    Discovery.categories(standard_params(conn, %{
      meta:         false,
      promotionals: false,
      inactive:     false,
    }))
  end

  def fetch_category(conn, params) do
    Discovery.category(standard_params(conn, %{
      id_or_slug: params["category"],
      images:     false,
    }))
  end
end
