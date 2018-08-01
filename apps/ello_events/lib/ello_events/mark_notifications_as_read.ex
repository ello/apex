defmodule Ello.Events.MarkNotificationsAsRead do
  use Ello.Events.Sidekiq

  defstruct [
    user_id: nil,
    last_notification_time: 0,
  ]

  def args(struct) do
    [
      %{
        user: %{active_record: %{id: struct.user_id, class: "User"}},
        last_notification_time: parse_last_notification_time(struct),
      }
    ]
  end

  defp parse_last_notification_time(%{last_notification_time: time}) when is_binary(time) do
    case DateTime.from_iso8601(time) do
      {:ok, dt, _} -> DateTime.to_unix(dt)
      _ -> 0
    end
  end
  defp parse_last_notification_time(%{last_notification_time: %DateTime{} = time}) do
    DateTime.to_unix(time)
  end
  defp parse_last_notification_time(%{last_notification_time: time}), do: time
end
