defmodule TH.Dash.StatusController do
  use TH.Dash.Web, :controller

  def ping(conn, _) do
    render(conn, :index)
  end
end
