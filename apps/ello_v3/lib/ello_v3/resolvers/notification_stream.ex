defmodule Ello.V3.Resolvers.NotificationStream do
  import Ello.V3.Resolvers.PostViewHelpers
  alias Ello.Notifications.Stream
  alias Ello.Events.MarkNotificationsAsRead

  def call(_parent, args, _resolver) do
    stream = Stream.fetch(args)


    if (!args.before), do: mark_notifications_as_read(args, hd(stream.models))

    {:ok, %{
      notifications: track(stream.models, args, kind: :notifications),
      is_last_page: length(stream.models) < args.per_page,
      next: stream.next,
    }}
  end

  defp mark_notifications_as_read(%{current_user: %{id: user_id}}, %{created_at: last_read_at}) do
    Ello.Events.publish(%MarkNotificationsAsRead{
      user_id: user_id,
      last_notification_time: last_read_at,
    })
  end
end
