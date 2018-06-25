defmodule Ello.Notifications.Stream.Client do
  alias Ello.Notifications.Stream
  alias Stream.Item

  @callback fetch(Stream.t) :: Stream.t
  @callback create(Item.t) :: :ok
  @callback delete(Item.t) :: :ok

  def fetch(%Stream{} = stream), do: client().fetch(stream)
  def create(%Item{} = item), do: client().create(item)
  def delete(%Item{} = item), do: client().delete(item)

  defp client() do
    Application.get_env(:ello_notifications, :stream_client, __MODULE__.HTTP)
  end
end
