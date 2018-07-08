defmodule Ello.Notifications.Stream.Client.HTTP do
  use HTTPoison.Base
  alias Ello.Notifications.Stream.{
    Client,
    Item,
  }
  @behaviour Client
  @ct {"content-type", "application/json"}
  @hackney_opts [pool: :notification_streams]


  @impl Client
  def fetch_notifications(%{current_user: %{id: user_id}} = stream) do
    params = to_params(stream)
    case get!(user_path(user_id), [], params: params, hackney: @hackney_opts) do
      %{status_code: 200} = resp -> parse_response(resp, stream)
    end
  end

  @impl Client
  def create_notification(item) do
    body = Item.as_json(item)
    case post!(user_path(item.user_id), body, [@ct], hackney: @hackney_opts) do
      %{status_code: 201} -> :ok
    end
  end

  # @impl Client
  # def delete_notifications(item) do
  #   # TODO
  # end

  @impl HTTPoison.Base
  def process_url(path), do: Application.get_env(:ello_notifications, :stream_service_url) <> path

  defp user_path(user_id), do: "/api/v1/users/#{user_id}/notifications"

  defp to_params(stream) do
    %{
      user_id: stream.current_user.id,
    }
  end

  defp parse_response(%{body: body}, stream) do
    Map.put(stream, :__response, Jason.decode!(body))
  end

end