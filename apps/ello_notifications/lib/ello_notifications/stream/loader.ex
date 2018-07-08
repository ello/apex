defmodule Ello.Notifications.Stream.Loader do
  alias Ello.Notifications.Stream
  alias Stream.Item

  def load(stream) do
    stream
    |> build_items
    |> load_related
  end

  defp build_items(%{__response: json} = stream) do
    items = Enum.map json, fn (j) ->
      %Item{
        user_id: j["user_id"],
        kind: j["kind"],
        subject_id: j["subject_id"],
        subject_type: j["subject_type"],
        created_at: j["created_at"],
        originating_user_id: j["originating_user_id"],
      }
    end

    Map.put(stream, :models, items)
  end

  defp load_related(stream) do
    stream
  end

end
