defmodule Ello.Grandstand.Client do
  alias Ello.Grandstand.{Impression, Client}

  @callback fetch_impressions(path :: String.t, params :: Map.t) :: {:ok, [Impression.t]} | {:error, String.t}

  @spec client() :: Module.t
  def client(), do: Application.get_env(:ello_grandstand, :client, Client.HTTP)

  @spec fetch_impressions(path :: String.t, options: Map.t) :: {:ok, [Impression.t]} | {:error, String.t}
  def fetch_impressions(path, params), do: client().fetch_impressions(path, params)
end
