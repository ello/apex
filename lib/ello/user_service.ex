defmodule Ello.UserService do

  def prefetch_counts(users) do
    # Get keys for each counter
    keys = Enum.flat_map users, fn(%{id: id}) ->
      [
        "user:#{id}:followers_counter",
        "user:#{id}:followed_users_counter",
        "user:#{id}:loves_counter",
        "user:#{id}:posts_counter",
      ]
    end

    # Get counts from redis
    {:ok, counts} = Ello.Redis.command(["MGET" | keys])

    # Add counts to users
    for user <- users,
        [followers, following, loves, posts] <- Enum.chunk(counts, 4) do
      Map.merge user, %{
        loves_count:     loves,
        posts_count:     posts,
        following_count: following,
        followers_count: followers,
      }
    end
  end
end
