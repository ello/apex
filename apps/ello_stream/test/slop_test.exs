defmodule Ello.SlopTest do
  use ExUnit.Case
  alias Ello.Stream.Slop

  test "it calculates default slop_factor for anonymous user" do
    factors = %{
      base_slop_factor: 1,
      nsfw_slop_factor: 2,
      nudity_slop_factor: 3,
    }
    assert Slop.slop_factor(%{}, factors) == 6
  end

  test "it calculates slop_factor for allow_nudity, allow_nsfw true" do
    factors = %{
      base_slop_factor: 1,
      nsfw_slop_factor: 2,
      nudity_slop_factor: 3,
    }
    assert Slop.slop_factor(%{allow_nudity: true, allow_nsfw: true}, factors) == 1
  end

  test "it calculates slop_factor for blocked users" do
    factors = %{
      base_slop_factor: 0,
      nsfw_slop_factor: 0,
      nudity_slop_factor: 0,

      block_slop_multiplier: 2,
      max_block_slop_factor: 100,
    }
    assert Slop.slop_factor(%{current_user: %{all_blocked_ids: [1, 2, 3]}}, factors) == 6
  end

end
