defmodule Ello.Stream.Client do
  alias Ello.Stream.Item

  @callback get_coalesced_stream(keys :: [String.t], pagination_slug :: String.t, limit: integer) :: Item.t
  @callback add_items(Item.t) :: :ok
  @callback delete_items(Item.t) :: :ok

  @spec client() :: Module.t
  def client() do
    Application.get_env(:ello_stream, :client, Ello.Stream.Client.Roshi)
  end

  @spec get_coalesced_stream(keys :: [String.t], pagination_slug :: String.t, limit: integer) :: Item.t
  def get_coalesced_stream(keys, pagination_slug, limit) do
    client().get_coalesced_stream(keys, pagination_slug, limit)
  end

  def add_items(items),    do: client().add_items(items)
  def delete_items(items), do: client().delete_items(items)
end
