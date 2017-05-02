defmodule Ello.V2.Pagination do
  import Plug.Conn
  alias Ello.Stream
  alias Ello.Core.Content.PostsPage
  alias Ello.Search.Page

  def add_pagination_headers(conn, path, %Stream{} = stream) do
    next = pagination_link(path, Map.take(stream, [:before, :per_page]))
    put_resp_header(conn, "link", ~s(<#{next}>; rel="next"))
  end
  def add_pagination_headers(conn, path, %PostsPage{} = page) do
    before = case page.before do
      nil -> ""
      date -> DateTime.to_iso8601(date)
    end

    next = pagination_link(path, %{before: before, per_page: page.per_page})

    conn
    |> put_resp_header("x-total-pages", "#{page.total_pages}")
    |> put_resp_header("x-total-count", "#{page.total_count}")
    |> put_resp_header("x-total-pages-remaining", "#{page.total_pages_remaining}")
    |> put_resp_header("link", ~s(<#{next}>; rel="next"))
  end
  def add_pagination_headers(conn, path, %Page{} = page) do
    next = pagination_link(path, %{page: page.next_page, per_page: page.per_page, terms: page.terms})

    conn
    |> put_resp_header("x-total-pages", "#{page.total_pages}")
    |> put_resp_header("x-total-count", "#{page.total_count}")
    |> put_resp_header("x-total-pages-remaining", "#{page.total_pages_remaining}")
    |> put_resp_header("link", ~s(<#{next}>; rel="next"))
  end

  defp pagination_link(path, params) do
    %URI{
      scheme: "https",
      host:   webapp_host(),
      path:   "/api/v2" <> path,
      query:  URI.encode_query(params),
    } |> URI.to_string
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end
end
