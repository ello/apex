defmodule Ello.Stream do
  alias __MODULE__.Client

  defstruct [
    keys:           [],
    current_user:   nil,
    allow_nsfw:     false,
    allow_nudity:   false,
    per_page:       25,
    before:         nil,
    posts:          [],
    __batches:      0,
    __stream_items: [],
    __slop_factor:  0.0,
  ]

  def fetch(opts) do
    __MODULE__
    |> struct(opts)
    |> set_slop
    |> do_fetch
  end

  @max_batches_per_request 3

  # When max number of batches still doesn't have enough posts, return stream
  defp do_fetch(%{__batches: @max_batches_per_request} = stream), do: stream

  # When posts length >= requested page length return stream
  defp do_fetch(%{posts: p, per_page: per} = stream)
       when length(p) >= per,
       do: stream

  # TODO: Last page, stream_items < per_page

  defp do_fetch(stream) do
    stream
    |> fetch_stream_items
    |> fetch_filtered_posts
    |> Map.update!(:__batches, &(&1 + 1))
    |> do_fetch
  end

  defp set_slop(stream) do
    stream
  end

  defp fetch_stream_items(stream) do
    stream_items = Client.get_coalesced_stream(stream.keys, stream.before)
    Map.put(stream, :__stream_items, stream_items)
  end

  defp fetch_filtered_posts(stream) do
    stream
  end

end
