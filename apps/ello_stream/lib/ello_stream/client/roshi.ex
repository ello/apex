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
    case put!("/streams", body, [], hackney: [pool: :roshi]) do
      %{status_code: 201} -> :ok
    end
  end

  @doc """
  Delete %Items{} from roshi.
  """
  @spec delete_items([Item.t]) :: :ok
  def delete_items(items) do
    body = Poison.encode!(Enum.map(items, &Item.format_stream_id/1))
    case request!(:delete, "/streams", body, [], hackney: [pool: :roshi]) do
      %{status_code: 200} -> :ok
    end
  end

  @doc """
  Get %Items{} from roshi for given keys, slug, limit.
  """
  @spec get_coalesced_stream([String.t], String.t, integer) :: %{items: [Item.t], next_link: String.t}
  def get_coalesced_stream(keys, pagination_slug, limit) do
    params = [{"limit", limit}, {"from", pagination_slug}]
    body = Poison.encode!(%{streams: Enum.map(keys, &Item.format_stream_id/1)})
    case post!("/streams/coalesce", body, [], [params: params, hackney: [pool: :roshi]]) do
      %{status_code: 200, body: "[]"} -> %{items: [], next_link: pagination_slug}
      %{status_code: 200, body: resp, headers: headers} ->
        %{items: Poison.decode!(resp, as: [%Item{}]), next_link: next_link(headers)}
    end
  end

  defp next_link(headers) do
    Enum.find_value headers, fn
      {"Link", value} -> extract_link_from_header(value)
      _ -> nil
    end
  end

  defp extract_link_from_header(link) do
    case Regex.run(~r/^<.*\?(.*)>; rel="next"$/, link) do
      [_, query_string | _] ->
        query_string
        |> URI.query_decoder
        |> Enum.into(%{})
        |> Map.get("from")
      _ -> nil
    end
  end

  @stream_service_url Application.get_env(:ello_stream, :service_url)

  @doc false
  def process_url(url) do
    @stream_service_url <> url
  end
end
