defmodule TH.Dash.StatusView do
  use TH.Dash.Web, :view

  def render("index.json", _) do
    %{
      status: "okay",
      ping: "pong",
    }
  end
end
