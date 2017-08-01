defmodule Ello.V2.Pagination do
  import Plug.Conn
  alias Ello.Stream
  alias Ello.Core.Content.Post
  alias Ello.Core.Contest.ArtistInviteSubmission
  alias Ello.Search.Post.Search, as: PostSearch
  alias Ello.Search.User.Search, as: UserSearch
  import Ello.V2.StandardParams

  def add_pagination_headers(conn, path, %Stream{} = stream) do
    next = pagination_link(path, Map.take(stream, [:before, :per_page]))
    put_resp_header(conn, "link", ~s(<#{next}>; rel="next"))
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
    conn
    |> add_last_page_header(subs)
    |> add_pagination_headers(path, %{
      before:   DateTime.to_iso8601(last.created_at),
      per_page: conn.params["per_page"] || 10,
      status:   conn.params["status"] || "approved",
    })
  end
  def add_pagination_headers(conn, path, [%Post{} | _] = posts) do
    last = List.last(posts)
    conn
    |> add_last_page_header(posts)
    |> add_pagination_headers(path, %{
      before:   DateTime.to_iso8601(last.created_at),
      per_page: conn.params["per_page"] || 25
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

  @filter_slop 3 # Don't 204 if one blocked post gets filtered out
  defp add_last_page_header(conn, structs) do
    requested = standard_params(conn, %{})[:per_page]
    if requested - @filter_slop > length(structs) do
      conn
      |> put_resp_header("x-last-page", "true")
      |> put_resp_header("x-total-pages-remaining", "0")
    else
      conn
    end
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end
end
