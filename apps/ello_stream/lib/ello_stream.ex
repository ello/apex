defmodule Ello.Stream do
  # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
  # newrelic until we have bandwidth to update our code, maybe to new_relic
  # import NewRelicPhoenix, only: [measure_segment: 2]
  import Ello.Core, only: [measure_segment: 2]
  alias __MODULE__.Slop
  alias __MODULE__.Client
  alias Ello.Core.Content

  defstruct [
    keys:           [],
    current_user:   nil,
    allow_nsfw:     false,
    allow_nudity:   false,
    per_page:       25,
    before:         nil,
    posts:          [],
    preloads:       nil,
    __batches:      0,
    __stream_items: [],
    __limit:        nil,
    __slop_factor:  nil,
  ]

  def fetch(opts) do
    __MODULE__
    |> struct(opts)
    |> set_slop
    |> do_fetch
  end

  def key(kind), do: Ello.Stream.Key.find(kind)
  def key(arg, kind), do: Ello.Stream.Key.find(arg, kind)

  # Set in module attribute so we can pattern match.
  @max_batches_per_request Application.get_env(:ello_stream, :batches_per_request)

  # When max number of batches still doesn't have enough posts, return stream
  defp do_fetch(%{__batches: @max_batches_per_request} = stream), do: stream

  # When posts length >= requested page length return stream
  defp do_fetch(%{posts: p, per_page: per} = stream)
       when length(p) >= per,
       do: stream

  # When we have made at least one request (batches > 0) but the number of items
  # is less then the limit, we are on the last page
  defp do_fetch(%{__stream_items: items, __limit: limit, __batches: batches} = stream)
       when length(items) < limit and batches > 0,
       do: stream

  defp do_fetch(stream) do
    stream
    |> fetch_stream_items
    |> fetch_filtered_posts
    |> Map.update!(:__batches, &(&1 + 1))
    |> do_fetch
  end

  defp set_slop(stream) do
    slop_factor = Slop.slop_factor(stream)
    stream
    |> Map.put(:__slop_factor, slop_factor)
    |> Map.put(:__limit, trunc(slop_factor * stream.per_page))
  end

  defp fetch_stream_items(stream) do
    measure_segment {:ext, "Stream.get_coalesced_stream"} do
      %{items: stream_items, next_link: next_link} = Client.get_coalesced_stream(stream.keys, stream.before, stream.__limit)
    end

    stream
    |> Map.put(:__stream_items, stream_items)
    |> Map.put(:before, next_link)
  end

  defp fetch_filtered_posts(stream) do
    post_ids = Enum.map(stream.__stream_items, &(String.to_integer(&1.id)))
    filters = Map.take(stream, [:current_user, :allow_nsfw, :allow_nudity, :preloads])
    posts = Content.posts(Map.merge(filters, %{ids: post_ids}))
    Map.put(stream, :posts, stream.posts ++ posts)
  end

end
