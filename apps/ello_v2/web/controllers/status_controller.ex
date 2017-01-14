defmodule Ello.V2.StatusController do
  use Ello.V2.Web, :controller

  def ping(conn, _) do
    send_resp(conn, 200, "pong?")
  end
end
