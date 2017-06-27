defmodule Ello.Serve.WebappHelpers do
  def webapp_url(path) do
    %URI{
      scheme: "https",
      host:   webapp_host(),
      path:   path,
    } |> URI.to_string
  end

  def username(%{name: nil, username: username}), do: "@" <> username
  def username(%{name: name, username: username}), do: "#{name} (@#{username})"

  def time(time), do: Timex.format!(time, "{RFC822}")

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end
end
