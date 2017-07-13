defmodule Ello.V2.Pagination do
  import Plug.Conn
  alias Ello.Stream
  alias Ello.Core.Content.PostsPage
  alias Ello.Core.Contest.ArtistInviteSubmission
  alias Ello.Search.Post.Search, as: PostSearch
  alias Ello.Search.User.Search, as: UserSearch

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
  def add_pagination_headers(conn, path, %{__struct__: struct} = search) when struct in [PostSearch, UserSearch] do
    next = pagination_link(path, %{
      page: search.next_page,
      per_page: search.per_page,
      terms: search.terms
    })

    conn
    |> put_resp_header("x-total-pages", "#{search.total_pages}")
    |> put_resp_header("x-total-count", "#{search.total_count}")
    |> put_resp_header("x-total-pages-remaining", "#{search.total_pages_remaining}")
    |> put_resp_header("link", ~s(<#{next}>; rel="next"))
  end
  def add_pagination_headers(conn, path, [%ArtistInviteSubmission{} | _] = subs) do
    last = List.last(subs)
    add_pagination_headers(conn, path, %{
      before:   last.created_at,
      per_page: conn.params["per_page"] || 10,
      status:   conn.params["status"] || "approved",
    })
  end
  def add_pagination_headers(conn, path, params) do
    next = pagination_link(path, params)
    put_resp_header(conn, "link", ~s(<#{next}>; rel="next"))
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
