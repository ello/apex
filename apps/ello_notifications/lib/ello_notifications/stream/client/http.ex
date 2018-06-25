defmodule Ello.Notifications.Stream.Client.HTTP do
  use HTTPoison.Base
  alias Ello.Notifications.Stream.{
    Client,
    Item,
  }
  @behaviour Client

  @hackney_opts [pool: :notification_streams]

  @impl
  def fetch(%{current_user: %{id: user_id}} = stream) do
    params = to_params(stream)
    case get!("/api/v1/users/#{user_id}/notifications", [], params: params, hackney: @hackney_opts) do
      %{status_code: 200} = resp -> parse_response(resp, stream)
    end
  end

  @impl
  def create(item) do
    # TODO
  end

  @impl
  def delete(item) do
    # TODO
  end

  @impl
  def process_url(url), do: Application.get_env(:ello_notifications, :stream_service_url) <> url

  defp timeout, do: Application.get_env(:ello_notification, :stream_service_timeout)

  defp to_params(stream) do
    %{
      user_id: stream.current_user.id,
    }
  end

  defp parse_response(resp, stream) do
    stream
  end
end
