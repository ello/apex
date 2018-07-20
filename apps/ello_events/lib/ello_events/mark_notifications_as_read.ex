defmodule Ello.Events.MarkNotificationsAsRead do
  use Ello.Events.Sidekiq

  defstruct [
    user_id: nil,
    last_notification_time: 0,
  ]

  def args(map) do
    [
      Map.from_struct(map),
    ]
  end
end
