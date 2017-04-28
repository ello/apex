defmodule Ello.Search.UserSearchTest do
  use Ello.Search.Case
  alias Ello.Search.{UserIndex, UserSearch}
  alias Ello.Core.{Repo, Factory, Network}

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    current_user = Factory.insert(:user)
    user         = Factory.insert(:user)
    lana32d      = Factory.insert(:user, %{id: 1, username: "lanakane32d"})
    lanakane     = Factory.insert(:user, %{id: 2, username: "lanakane"})
    lanabandero  = Factory.insert(:user, %{id: 3, username: "lana-bandero"})
    locked_user  = Factory.insert(:user, %{locked_at: DateTime.utc_now})
    spam_user    = Factory.insert(:user)
    nsfw_user    = Factory.insert(:user, settings: %{posts_adult_content: true})
    nudity_user  = Factory.insert(:user, settings: %{posts_nudity: true})
    private_user = Factory.insert(:user, %{is_public: false})

    UserIndex.delete
    UserIndex.create
    UserIndex.add(user)
    UserIndex.add(lana32d)
    UserIndex.add(lanakane)
    UserIndex.add(lanabandero)
    UserIndex.add(locked_user)
    UserIndex.add(spam_user, %{is_spammer: true})
    UserIndex.add(nsfw_user)
    UserIndex.add(nudity_user)
    UserIndex.add(private_user)
    {:ok,
      user: user,
      locked_user: locked_user,
      spam_user: spam_user,
      nsfw_user: nsfw_user,
      nudity_user: nudity_user,
      private_user: private_user,
      current_user: current_user,
      lana32d: lana32d,
      lanakane: lanakane,
      lanabandero: lanabandero
    }
  end

  test "username_search - scores more exact matches higher", context do
    results = UserSearch.username_search(%{terms: context.user.username, current_user: context.current_user}).results
    assert hd(results).id == context.user.id
  end

  test "username_search - does not include locked users", context do
    results = UserSearch.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.locked_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes spamified users", context do
    results = UserSearch.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes nsfw users", context do
    results = UserSearch.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes nudity users", context do
    results = UserSearch.username_search(%{terms: context.spam_user.username, current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.spam_user.id])

    results = UserSearch.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.spam_user.id == hd(Enum.map(results, &(&1.id)))
  end

  test "username_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = UserSearch.username_search(%{terms: "username", current_user: current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = UserSearch.username_search(%{terms: "username", current_user: current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - lana test", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.lana32d.id])

    results = UserSearch.username_search(%{terms: "lana", current_user: context.current_user}).results
    assert context.lana32d.id == hd(Enum.map(results, &(&1.id)))
    assert context.lanakane.id in Enum.map(results, &(&1.id))
    assert context.lanabandero.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include spamified users", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include locked users", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.locked_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include nsfw users if client disallows nsfw", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - includes nsfw users if client allows nsfw", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: context.current_user}).results
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include nudity users if client disallows nudity", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - includes nudity users if client allows nudity", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: true, current_user: context.current_user}).results
    assert context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: current_user}).results
    refute context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: current_user}).results
    refute context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.nsfw_user.id])

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: context.current_user}).results
    assert context.nsfw_user.id == hd(Enum.map(results, &(&1.id)))
    assert context.user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - pagination", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user}).results
    assert length(Enum.map(results, &(&1.id))) == 4

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, per_page: "2"}).results
    assert length(Enum.map(results, &(&1.id))) == 2

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, page: "2", per_page: "2"}).results
    assert length(Enum.map(results, &(&1.id))) == 2

    results = UserSearch.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, page: "3", per_page: "2"}).results
    assert length(Enum.map(results, &(&1.id))) == 0
  end

  test "user_search - filters private users if no current user", context do
    results = UserSearch.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: nil}).results

    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.private_user.id in Enum.map(results, &(&1.id))
  end
end
