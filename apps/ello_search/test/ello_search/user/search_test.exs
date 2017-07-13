defmodule Ello.Search.User.SearchTest do
  use Ello.Search.Case
  alias Ello.Search.User.{Index, Search}
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
    archer       = Factory.insert(:user, %{username: "archer"})
    casey        = Factory.insert(:user, %{username: "dcdoran", name: "Casey Doran"})
    dcdoran122   = Factory.insert(:user, %{username: "dcdoran122"})
    dcdoran11888 = Factory.insert(:user, %{username: "dcdoran11888"})
    lucian       = Factory.insert(:user, %{username: "lucian", name: "Lucian Föhr"})
    todd         = Factory.insert(:user, %{username: "todd", name: "Todd Berger"})
    toddreed     = Factory.insert(:user, %{username: "toddreed", name: "Todd Reed"})

    Index.delete
    Index.create
    Index.add(user)
    Index.add(lana32d)
    Index.add(lanakane)
    Index.add(lanabandero)
    Index.add(locked_user)
    Index.add(spam_user, %{is_spammer: true})
    Index.add(nsfw_user)
    Index.add(nudity_user)
    Index.add(private_user)
    Index.add(archer)
    Index.add(casey)
    Index.add(dcdoran122)
    Index.add(dcdoran11888)
    Index.add(lucian)
    Index.add(todd)
    Index.add(toddreed)

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
      lanabandero: lanabandero,
      archer: archer,
      casey: casey,
      dcdoran122: dcdoran122,
      dcdoran11888: dcdoran11888,
      lucian: lucian,
      todd: todd,
      toddreed: toddreed
    }
  end

  test "username_search - scores more exact matches higher", context do
    results = Search.username_search(%{terms: context.user.username, current_user: context.current_user}).results
    assert hd(results).id == context.user.id
  end

  test "username_search - removes @ sign if provided", context do
    results = Search.username_search(%{terms: "@#{context.user.username}", current_user: context.current_user}).results
    assert hd(results).id == context.user.id
  end

  test "username_search - does not include locked users", context do
    results = Search.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.locked_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes spamified users", context do
    results = Search.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes nsfw users", context do
    results = Search.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - includes nudity users", context do
    results = Search.username_search(%{terms: "username", current_user: context.current_user}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    assert context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.spam_user.id])

    results = Search.username_search(%{terms: "username", current_user: context.current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:followed_users_id_cache"])
    assert context.spam_user.id == hd(Enum.map(results, &(&1.id)))
  end

  test "username_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = Search.username_search(%{terms: "username", current_user: current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:block_id_cache"])

    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = Search.username_search(%{terms: "username", current_user: current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:inverse_block_id_cache"])
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "username_search - lana test", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.lana32d.id])

    results = Search.username_search(%{terms: "lana", current_user: context.current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:followed_users_id_cache"])
    assert context.lana32d.id == hd(Enum.map(results, &(&1.id)))
    assert context.lanakane.id in Enum.map(results, &(&1.id))
    assert context.lanabandero.id in Enum.map(results, &(&1.id))
  end

  test "username_search - dashes supported", context do
    results = Search.username_search(%{terms: "lana-", current_user: context.current_user}).results
    assert context.lanabandero.id in Enum.map(results, &(&1.id))
  end

  test "username_search - @todd test", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.toddreed.id])
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.todd.id])

    results = Search.user_search(%{terms: "@todd", current_user: context.current_user, allow_nsfw: false, allow_nudity: false}).results
    assert context.todd.id == hd(Enum.map(results, &(&1.id)))
    assert context.toddreed.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include spamified users", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.spam_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include locked users", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.locked_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include nsfw users if client disallows nsfw", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - includes nsfw users if client allows nsfw", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: context.current_user}).results
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include nudity users if client disallows nudity", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: context.current_user}).results
    refute context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - includes nudity users if client allows nudity", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: true, current_user: context.current_user}).results
    assert context.nudity_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:block_id_cache"])
    refute context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:inverse_block_id_cache"])
    refute context.user.id in Enum.map(results, &(&1.id))
    assert context.nsfw_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.nsfw_user.id])

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: false, current_user: context.current_user}).results
    Redis.command(["DEL", "user:#{context.current_user.id}:followed_users_id_cache"])
    assert context.nsfw_user.id == hd(Enum.map(results, &(&1.id)))
    assert context.user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - pagination", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user}).results
    assert length(Enum.map(results, &(&1.id))) == 4

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, per_page: 2}).results
    assert length(Enum.map(results, &(&1.id))) == 2

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, page: 2, per_page: 2}).results
    assert length(Enum.map(results, &(&1.id))) == 2

    results = Search.user_search(%{terms: "username", allow_nsfw: true, allow_nudity: true, current_user: context.current_user, page: 3, per_page: 2}).results
    assert length(Enum.map(results, &(&1.id))) == 0
  end

  test "user_search - filters private users if no current user", context do
    results = Search.user_search(%{terms: "username", allow_nsfw: false, allow_nudity: false, current_user: nil}).results
    assert context.user.id in Enum.map(results, &(&1.id))
    refute context.private_user.id in Enum.map(results, &(&1.id))
  end

  test "user_search - build user query to prefer username if terms starts with @", context do
    results = Search.user_search(%{terms: "@archer", allow_nsfw: false, allow_nudity: false, current_user: nil}).results
    assert context.archer.id in Enum.map(results, &(&1.id))
  end

  test "user_search - returns relevant results based on name", context do
    results = Search.user_search(%{terms: "casey doran", allow_nsfw: false, allow_nudity: false, current_user: nil}).results
    assert context.casey.id in Enum.map(results, &(&1.id))
  end

  test "user_search - does not return results if terms are irrelevant", context do
    results = Search.user_search(%{terms: "case doorknob", allow_nsfw: false, allow_nudity: false, current_user: nil}).results
    refute context.casey.id in Enum.map(results, &(&1.id))
  end

  test "user_search - @dcdoran test", context do
    results = Search.user_search(%{terms: "@dcdoran", current_user: context.current_user, allow_nsfw: false, allow_nudity: false}).results
    assert context.casey.id == hd(Enum.map(results, &(&1.id)))
    assert context.dcdoran122.id in Enum.map(results, &(&1.id))
    assert context.dcdoran11888.id in Enum.map(results, &(&1.id))
  end

  test "user_search - Lucian Föhr test (special characters)", context do
    results = Search.user_search(%{terms: "Lucian Föhr", current_user: context.current_user, allow_nsfw: false, allow_nudity: false}).results
    assert context.lucian.id == hd(Enum.map(results, &(&1.id)))
    assert length(Enum.map(results, &(&1.id))) == 1
  end

  test "user_search - Lucian Fohr test", context do
    results = Search.user_search(%{terms: "lucian fohr", current_user: context.current_user, allow_nsfw: false, allow_nudity: false}).results
    assert context.lucian.id == hd(Enum.map(results, &(&1.id)))
    assert length(Enum.map(results, &(&1.id))) == 1
  end

end
