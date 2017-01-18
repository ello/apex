defmodule Ello.V2.StatusController do
  use Ello.V2.Web, :controller

  def ping(conn, _) do
    render(conn, :index)
  end
end
