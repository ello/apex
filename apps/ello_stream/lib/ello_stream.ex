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
    __limit:        25,
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

  # When stream items present but less then limit we are on the last page
  defp do_fetch(%{__stream_items: items, __limit: limit} = stream)
       when length(items) < limit and length(items) > 0,
       do: stream

  defp do_fetch(stream) do
    stream
    |> IO.inspect
    |> fetch_stream_items
    |> fetch_filtered_posts
    |> Map.update!(:__batches, &(&1 + 1))
    |> do_fetch
  end

  defp set_slop(stream) do
    slop_factor = slop_factor(stream)
    stream
    |> Map.put(:__slop_factor, slop_factor)
    |> Map.put(:__limit, slop_factor * stream.per_page)
  end

  def slop_factor(stream) do
    Application.get_env(:ello_stream, :base_slop_factor) *
      nsfw_slop_factor(stream) *
      nudity_slop_factor(stream) *
      blocked_users_slop_factor(stream)
  end

  @block_multiplier Application.get_env(:ello_stream, :block_slop_multiplier)
  @max_block_slop   Application.get_env(:ello_stream, :max_block_slop_factor)
  defp blocked_users_slop_factor(%{current_user: nil}), do: 0.0
  defp blocked_users_slop_factor(%{current_user: %{all_blocked_ids: []}}), do: 0.0
  defp blocked_users_slop_factor(%{current_user: %{all_blocked_ids: blocked}}) do
    min(length(blocked) * @block_multiplier, @max_block_slop)
  end

  @nsfw_slop_factor Application.get_env(:ello_stream, :nsfw_slop_factor)
  defp nsfw_slop_factor(%{allow_nsfw: true}), do: 0.0
  defp nsfw_slop_factor(%{allow_nsfw: false}), do: @nsfw_slop_factor

  @nudity_slop_factor Application.get_env(:ello_stream, :nudity_slop_factor)
  defp nudity_slop_factor(%{allow_nudity: true}), do: 0.0
  defp nudity_slop_factor(%{allow_nudity: false}), do: @nudity_slop_factor

  defp fetch_stream_items(stream) do
    stream_items = Client.get_coalesced_stream(stream.keys, stream.before, stream.__limit)
    Map.put(stream, :__stream_items, stream_items)
  end

  defp fetch_filtered_posts(stream) do
    stream
  end
end
