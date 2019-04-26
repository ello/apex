defmodule TH.Dash.StatusController do
  use TH.Dash.Web, :controller

  def ping(conn, _) do
    json(conn, %{
      status: "okay",
      ping: "pong",
    })
  end
end
