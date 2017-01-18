defmodule Ello.V2.StatusView do
  use Ello.V2.Web, :view

  def render("index.json", _) do
    %{
      status: "okay",
      ping: "pong",
    }
  end

  def render("index.html", _) do
    "PONG"
  end
end
