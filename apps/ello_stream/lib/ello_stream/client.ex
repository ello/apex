defmodule Ello.Stream.Client do

  @callback get_coalesced_stream(keys :: [String.t], pagination_slug :: String.t, limit: integer) :: Item.t

  @spec client() :: Module.t
  def client() do
    Application.get_env(:ello_stream, :client, Ello.Stream.Client.Roshi)
  end

  @spec get_coalesced_stream(keys :: [String.t], pagination_slug :: String.t, limit: integer) :: Item.t
  def get_coalesced_stream(keys, pagination_slug, limit) do
    client().get_coalesced_stream(keys, pagination_slug, limit)
  end
end

defmodule Ello.Stream.Item do
  @type t :: %__MODULE__{id: String.t, stream_id: String.t, ts: Calendar.t, type: integer}
  defstruct [id: "", stream_id: "", ts: nil, type: 0]
end

defmodule Ello.Stream.Client.Roshi do
  @behaviour Ello.Stream.Client

  def get_coalesced_stream(keys, pagination_slug, limit) do
    # post /streams/coalesce?limit=limit&(pagination_slug=pagination_slug)
    # body = %{streams: keys}
    # resp
  end

  @stream_prefix Application.get_env(:ello_stream, :prefix)
  @stream_env    Application.get_env(:ello_stream, :env)

  defp format_stream_id(key) do
    [@stream_prefix, @stream_env, key]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(":")
  end
end

defmodule Ello.Stream.Client.Test do
  @behaviour Ello.Stream.Client

  def get_coalesced_stream(keys, pagination_slug, limit) do
    # Something something agent
  end
end
