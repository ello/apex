defmodule Ello.Feeds.DefaultToRSS do
  @moduledoc """
  Adds the accepts `application/rss-xml` header if the request has no accepts.

  This ensures even misbehaving clients/feed readers get an RSS feed.
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case get_req_header(conn, "accepts") do
      [] -> put_req_header(conn, "accepts", "application/rss-xml")
      _  -> conn
    end
  end
end
