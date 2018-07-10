defmodule Ello.Notifications.Stream.Client do
  alias Ello.Notifications.Stream
  alias Stream.Item

  @typep idee :: String.t | Integer.t

  @callback fetch_notifications(Stream.t) :: Stream.t
  @callback create_notification(Item.t) :: :ok
  @callback delete_notifications(%{
    optional(:user_id) => idee,
    optional(:subject_id) => idee,
    optional(:subject_type) => String.t,
  }) :: :ok

  def fetch(%Stream{} = stream), do: client().fetch_notifications(stream)
  def create(%Item{errors: []} = item), do: client().create_notification(item)
  def create(%Item{errors: errors}), do: {:error, errors}
  def delete_many(args), do: client().delete_notifications(args)

  defp client() do
    Application.get_env(:ello_notifications, :stream_client, __MODULE__.HTTP)
  end
end
