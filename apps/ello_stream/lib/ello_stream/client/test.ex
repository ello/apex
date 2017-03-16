defmodule Ello.Stream.Client.Test do
  @behaviour Ello.Stream.Client

  def start do
    Agent.start(fn -> %{} end, name: __MODULE__)
  end

  def reset do
    Agent.update(__MODULE__, fn(_) -> %{} end)
  end

  def add_items(items) do
    Agent.update(__MODULE__, fn(state) ->
      Enum.reduce(items, state, fn(item, state) ->
        Map.update(state, item.stream_id, [item], &([item | &1]))
      end)
    end)
  end

  def delete_items(items) do
    Agent.update(__MODULE__, fn(state) ->
      Enum.reduce(items, state, fn(item, state) ->
        new_items = filter_items(state[item.stream_id], item)
        Map.put(state, item.stream_id, new_items)
      end)
    end)
  end

  defp filter_items(nil, _), do: []
  defp filter_items([], _), do: []
  defp filter_items(stream_items, remove_item) do
    Enum.reject(stream_items, &(&1.id == item.id))
  end

  def get_coalesced_stream(keys, pagination_post_id, limit) do
    Agent.get(__MODULE__, fn(state) ->
      all_items = keys
                  |> Enum.flat_map(&(state[&1] || []))
                  |> Enum.sort_by(&(&1.ts), &>=/2)
                  |> drop_until_item(pagination_post_id)
                  |> Enum.take(limit)
      case all_items do
        [] -> %{items: [], next_link: pagination_post_id}
        _  -> %{items: all_items, next_link: List.last(all_items).id}
      end
    end)
  end

  defp drop_until_item(items, nil), do: items
  defp drop_until_item(items, pagination_post_id) do
    items
    |> Enum.drop_while(&(&1.id != pagination_post_id))
    |> Enum.drop(1)
  end
end
