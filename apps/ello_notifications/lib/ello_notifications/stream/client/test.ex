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
  def fetch_notifications(%{current_user: %{id: user_id}, per_page: limit} = stream) do
    Agent.get __MODULE__, fn(state) ->
      results = state
                |> Enum.filter(&(&1["user_id"] == user_id))
                |> Enum.sort_by(&(&1["created_at"]), &>=/2)
                # TODO - pagination
                |> Enum.take(limit)
      Map.merge(stream, %{
        __response: results,
        #todo - pagination
      })
    end
  end

  @impl Client
  def create_notification(item) do
    body = item
           |> Item.as_json
           |> Enum.reduce(%{}, fn({k, v}, a) -> Map.put(a, Atom.to_string(k), v) end)
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
