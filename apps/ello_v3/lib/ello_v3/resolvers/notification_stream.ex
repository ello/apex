defmodule Ello.V3.Resolvers.NotificationStream do
  import Ello.V3.Resolvers.PostViewHelpers
  alias Ello.Notifications.Stream
  alias Ello.Events.MarkNotificationsAsRead
  alias Ello.Core.Network.User

  def call(_parent, args, _resolver) do
    stream = Stream.fetch(args)

    if (!args.before), do: mark_notifications_as_read(args, hd(stream.models))

    {:ok, %{
      notifications: track(stream.models, args, kind: :notifications),
      is_last_page: length(stream.models) < args.per_page,
      next: stream.next,
    }}
  end

  def new_content(_parent, %{current_user: current_user} = args, _resolution) do
    with stream <- Stream.fetch(Map.merge(args, %{preload: false, per_page: 1})),
         %{models: [%{created_at: newest} | _]} <- stream,
         last_read when is_number(last_read) <- User.last_read_notification_time(current_user),
         {:ok, newest_dt, _} <- DateTime.from_iso8601(newest),
         {:ok, last_read_dt} <- DateTime.from_unix(last_read),
         1 <- Timex.compare(newest_dt, last_read_dt, :seconds) do
      {:ok, %{new_content: true}}
    else
      nil -> {:ok, %{new_content: true}}
      _ -> {:ok, %{new_content: false}}
    end
  end

  defp mark_notifications_as_read(%{current_user: %{id: user_id}}, %{created_at: last_read_at}) do
    Ello.Events.publish(%MarkNotificationsAsRead{
      user_id: user_id,
      last_notification_time: last_read_at,
    })
  end
end
