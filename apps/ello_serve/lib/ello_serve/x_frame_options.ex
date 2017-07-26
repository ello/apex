defmodule Ello.Serve.XFrameOptions do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, :deny),
    do: put_resp_header(conn, "x-frame-options", "DENY")
  def call(conn, :same_origin),
    do: put_resp_header(conn, "x-frame-options", "SAMEORIGIN")
  def call(conn, _),
    do: conn
end
