defmodule Ello.Stream do
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

  defp set_slop(%{__slop_factor: nil} = stream), do: set_slop(Map.delete(stream, :__slop_factor))
  defp set_slop(%{__limit: nil} = stream), do: set_slop(Map.delete(stream, :__limit))
  defp set_slop(stream) do
    slop_factor = Slop.slop_factor(stream)
    stream
    |> Map.put_new(:__slop_factor, slop_factor)
    |> Map.put_new(:__limit, trunc(slop_factor * stream.per_page))
  end

  defp fetch_stream_items(stream) do
    %{items: stream_items, next_link: next_link} = Client.get_coalesced_stream(stream.keys, stream.before, stream.__limit)

    stream
    |> Map.put(:__stream_items, stream_items)
    |> Map.put(:before, next_link)
  end

  defp fetch_filtered_posts(stream) do
    post_ids = Enum.map(stream.__stream_items, &(String.to_integer(&1.id)))
    filters = Map.take(stream, [:current_user, :allow_nsfw, :allow_nudity])
    posts = Content.posts_by_ids(post_ids, filters)
    Map.put(stream, :posts, stream.posts ++ posts)
  end

end
