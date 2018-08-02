defmodule Ello.V3.Resolvers.NotificationStream do
  import Ello.V3.Resolvers.PostViewHelpers
  import Ello.V3.Resolvers.PaginationHelpers
  alias Ello.Notifications.Stream
  alias Ello.Events.MarkNotificationsAsRead
  alias Ello.Core.Network.User

  def call(_parent, args, _resolver) do
    stream = Stream.fetch(args)

    with %{before: b4} when b4 in [nil, ""] <- args,
         [newest | _] <- stream.models do
      mark_notifications_as_read(args, newest)
    end

    {:ok, %{
      notifications: track(stream.models, args, kind: :notifications),
      is_last_page: is_last_page(args, stream.models),
      next: stream.next,
    }}
  end

  def new_content(_parent, %{current_user: current_user} = args, _resolution) do
    with stream <- Stream.fetch(Map.merge(args, %{preload: false, per_page: 1})),
         %{models: [%{created_at: newest_dt} | _]} <- stream,
         last_read when is_number(last_read) <- User.last_read_notification_time(current_user),
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
