defmodule Ello.Stream.Client.Roshi do
  alias Ello.Stream.{Item, Client}
  @behaviour Client
  use HTTPoison.Base

  @doc """
  Add %Items{} to roshi.
  """
  @spec add_items([Item.t]) :: :ok
  def add_items(items) do
    body = Poison.encode!(Enum.map(items, &Item.format_stream_id/1))
    case put!("/streams", body) do
      %{status_code: 201} -> :ok
    end
  end

  @doc """
  Delete %Items{} from roshi.
  """
  @spec delete_items([Item.t]) :: :ok
  def delete_items(items) do
    body = Poison.encode!(Enum.map(items, &Item.format_stream_id/1))
    case delete!("/streams", body) |> IO.inspect do
      %{status_code: 200} -> :ok
    end
  end

  @doc """
  Get %Items{} from roshi for given keys, slug, limit.
  """
  @spec get_coalesced_stream([String.t], String.t, integer) :: Item.t
  def get_coalesced_stream(keys, pagination_slug, limit) do
    params = [{"limit", limit}, {"pagination_slug", pagination_slug}]
    body = Poison.encode!(%{streams: Enum.map(keys, &Item.format_stream_id/1)})
    case post!("/streams/coalesce", body, [], [params: params]) do
      %{status_code: 200, body: "[]"} -> []
      %{status_code: 200, body: resp} -> Poison.decode!(resp, as: [%Item{}])
    end
  end

  @stream_service_url Application.get_env(:ello_stream, :service_url)

  @doc false
  def process_url(url) do
    @stream_service_url <> url
  end
end
