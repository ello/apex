defmodule Ello.Serve.DefaultToHTML do
  @moduledoc """
  Adds the accepts `*/*` header if the request has no accept header.

  This ensures even clients not sending accepts headers get responses.
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case get_req_header(conn, "accepts") do
      [] -> put_req_header(conn, "accepts", "*/*")
      _  -> conn
    end
  end
end
