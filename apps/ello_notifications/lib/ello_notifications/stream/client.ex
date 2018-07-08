defmodule Ello.Notifications.Stream.Client do
  alias Ello.Notifications.Stream
  alias Stream.Item

  @callback fetch_notifications(Stream.t) :: Stream.t
  @callback create_notification(Item.t) :: :ok
  # @callback delete_user_notifications(user_id :: Integer.t) :: :ok
  # @callback delete_subject_notifications(user_id :: Integer.t) :: :ok

  def fetch(%Stream{} = stream), do: client().fetch_notifications(stream)
  def create(%Item{errors: []} = item), do: client().create_notification(item)
  def create(%Item{errors: errors}), do: {:error, errors}
  #def delete_stream(%Item{} = item), do: client().delete_notification(item)

  defp client() do
    Application.get_env(:ello_notifications, :stream_client, __MODULE__.HTTP)
  end
end
