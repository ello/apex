defmodule Ello.Stream.Client.RoshiTest do
  use Ello.Stream.Case
  alias Ello.Stream.Client.Roshi
  alias Ello.Stream.Item

  test "it adds and deletes from the stream" do
    roshi_items = [
      %Item{id: "1234", stream_id: "add_delete", ts: DateTime.utc_now, type: 0},
    ]
    assert :ok = Roshi.add_items(roshi_items)
    assert %{items: [%{id: "1234"}], next_link: _} = Roshi.get_coalesced_stream(["add_delete"], nil, 10)
    Roshi.delete_items(roshi_items)
    assert %{items: []} = Roshi.get_coalesced_stream(["add_delete"], "", 10)
  end
end
