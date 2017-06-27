defmodule Ello.Serve.Webapp.NoscriptView do
  use Ello.Serve.Web, :view

  def webapp_url(path) do
    %URI{
      scheme: "https",
      host:   webapp_host(),
      path:   path,
    } |> URI.to_string
  end

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end
end
