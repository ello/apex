defmodule Ello.Notifications.Stream.Client.Test do
  alias Ello.Notifications.Stream.{
    Client,
    Item,
  }
  @behaviour Client

  def start do
    Agent.start(fn -> [] end, name: __MODULE__)
  end

  def reset do
    Agent.update(__MODULE__, fn(_) -> [] end)
  end

  @impl Client
  def fetch_notifications(%{current_user: %{id: user_id}, per_page: limit, before: b4} = stream) do
    Agent.get __MODULE__, fn(state) ->
      results = state
                |> Enum.filter(&(&1["user_id"] == user_id))
                |> Enum.sort_by(&(&1["created_at"]), &(DateTime.from_iso8601(&1) >= DateTime.from_iso8601(&2)))
                |> paginate(b4, limit)
      Map.merge(stream, %{
        __response: results,
      })
    end
  end

  defp paginate(items, nil, limit), do: Enum.take(items, limit)
  defp paginate(items, before, limit) do
    items
    |> Enum.reject(&(DateTime.from_iso8601(&1["created_at"]) >= DateTime.from_iso8601(before)))
    |> Enum.take(limit)
  end

  @impl Client
  def create_notification(item) do
    body = item
           |> Item.to_json
           |> Jason.decode! # force to the same format as http by encoding and decoding
    Agent.update(__MODULE__, &([body | &1]))
  end

  @impl Client
  def delete_notifications(%{user_id: user_id}) do
    Agent.update __MODULE__, fn(state) ->
      Enum.reject(state, &(&1["user_id"] == user_id))
    end
  end
  def delete_notifications(%{subject_id: subject_id, subject_type: subject_type}) do
    Agent.update __MODULE__, fn(state) ->
      Enum.reject(state, &(&1["subject_id"] == subject_id && &1["subject_type"] == subject_type))
    end
  end
end
