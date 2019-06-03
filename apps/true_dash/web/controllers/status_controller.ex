defmodule TH.TrueDash.StatusController do
  use TH.TrueDash.Web, :controller

  def ping(conn, _) do
    json(conn, %{
      status: "okay",
      ping: "pong",
    })
  end
end
