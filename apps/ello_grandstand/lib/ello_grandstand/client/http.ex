defmodule Ello.Grandstand.Client.HTTP do
  alias Ello.Grandstand.{Impression, Client}
  @behaviour Client
  use HTTPoison.Base

  @doc """
  Get %Impressions{} from grandstand api.
  """
  def fetch_impressions(path, params) do
    params = Enum.map(params, fn({k, v}) -> {Atom.to_string(k), v} end)
    opts = [
      params: params,
      hackney: [
        pool: :grandstand,
        recv_timeout: timeout(),
        basic_auth: {username(), password()}
      ],
    ]
    case get!(path, [], opts) do
      %{status_code: 200, body: resp} -> handle_response(resp)
      %{status_code: 204, body: resp} -> handle_response(resp)
    end
  end

  defp handle_response(resp) do
    resp
    |> Poison.decode!(as: %{"data" => [%Impression{}]})
    |> Map.get("data")
    |> case do
      nil -> []
      list -> list
    end
  end

  @doc false
  def process_url(url),
    do: Application.get_env(:ello_grandstand, :service_url) <> url

  defp timeout, do: Application.get_env(:ello_grandstand, :grandstand_timeout)

  defp username, do: Application.get_env(:ello_grandstand, :grandstand_username)

  defp password, do: Application.get_env(:ello_grandstand, :grandstand_password)
end
