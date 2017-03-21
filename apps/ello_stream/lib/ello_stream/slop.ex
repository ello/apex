defmodule Ello.Stream.Slop do

  @base_slop_factor      Application.get_env(:ello_stream, :base_slop_factor)
  @block_slop_multiplier Application.get_env(:ello_stream, :block_slop_multiplier)
  @max_block_slop_factor Application.get_env(:ello_stream, :max_block_slop_factor)
  @nsfw_slop_factor      Application.get_env(:ello_stream, :nsfw_slop_factor)
  @nudity_slop_factor    Application.get_env(:ello_stream, :nudity_slop_factor)

  def slop_factor(stream, factors \\ %{}) do
    base_slop_factor = factors[:base_slop_factor] || @base_slop_factor
    block_slop_multiplier = factors[:block_slop_multiplier] || @block_slop_multiplier
    max_block_slop_factor = factors[:max_block_slop_factor] || @max_block_slop_factor
    nsfw_slop_factor = factors[:nsfw_slop_factor] || @nsfw_slop_factor
    nudity_slop_factor = factors[:nudity_slop_factor] || @nudity_slop_factor

    base_slop_factor +
      calc_nsfw_slop_factor(stream, nsfw_slop_factor) +
      calc_nudity_slop_factor(stream, nudity_slop_factor) +
      calc_blocked_users_slop_factor(stream, block_slop_multiplier, max_block_slop_factor)
  end

  defp calc_blocked_users_slop_factor(%{current_user: %{all_blocked_ids: blocked}}, block_slop_multiplier, max_block_slop_factor)
    when length(blocked) > 0
  do
    min(length(blocked) * block_slop_multiplier, max_block_slop_factor)
  end
  defp calc_blocked_users_slop_factor(_, _, _), do: 0.0

  defp calc_nsfw_slop_factor(%{allow_nsfw: true}, _), do: 0.0
  defp calc_nsfw_slop_factor(_, nsfw_slop_factor), do: nsfw_slop_factor

  defp calc_nudity_slop_factor(%{allow_nudity: true}, _), do: 0.0
  defp calc_nudity_slop_factor(_, nudity_slop_factor), do: nudity_slop_factor

end
