defmodule Ello.Serve.WebappHelpers do
  def webapp_url(path, params \\ nil)
  def webapp_url(path, params) when is_list(params),
    do: webapp_url(path, Enum.into(params, %{}))
  def webapp_url(path, %{} = params),
    do: webapp_url(path, URI.encode_query(params))
  def webapp_url("/" <> path, params),
    do: webapp_url(path, params)
  def webapp_url("", params) do
    %URI{
      scheme: "https",
      host:   webapp_host(),
    } |> URI.to_string
  end
  def webapp_url(path, params) do
    %URI{
      scheme: "https",
      host:   webapp_host(),
      path:   "/" <> path,
      query:  params,
    } |> URI.to_string
  end

  def username(%{name: nil, username: username}), do: "@" <> username
  def username(%{name: name, username: username}), do: "#{name} (@#{username})"

  def time(time), do: Timex.format!(time, "{RFC822}")

  defp webapp_host do
    Application.get_env(:ello_v2, :webapp_host, "ello.co")
  end
end
