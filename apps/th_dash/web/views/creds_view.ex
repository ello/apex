defmodule TH.Dash.CredsView do
  use TH.Dash.Web, :view

  def render("index.json", %{data: data}) do
    data
  end
end
