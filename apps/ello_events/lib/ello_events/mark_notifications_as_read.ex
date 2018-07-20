defmodule Ello.Events.MarkNotificationsAsRead do
  use Ello.Events.Sidekiq

  defstruct [
    user_id: nil,
    last_notification_time: 0,
  ]

  def args(struct) do
    [
      user: struct.user_id,
      last_notification_time: struct.last_notification_time,
    ]
  end
end
