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
    {:ok, user: user, locked_user: locked_user, spam_user: spam_user, nsfw_user: nsfw_user, nudity_user: nudity_user, current_user: current_user, lana32d: lana32d, lanakane: lanakane, lanabandero: lanabandero}
  end

  test "username_search - scores more exact matches higher", context do
    response = UserSearch.username_search(context.user.username, %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.user.id) == hd(Enum.map(response.body["hits"]["hits"], &(&1["_id"])))
    assert to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include locked users", context do
    response = UserSearch.username_search(context.user.username, %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.locked_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes spamified users", context do
    response = UserSearch.username_search(context.user.username, %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes nsfw users", context do
    response = UserSearch.username_search(context.user.username, %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.nsfw_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - includes nudity users", context do
    response = UserSearch.username_search(context.spam_user.username, %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.nudity_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - following users should be given a higher score", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.spam_user.id])

    response = UserSearch.username_search("username", %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.spam_user.id) == hd(Enum.map(response.body["hits"]["hits"], &(&1["_id"])))
  end

  test "username_search - does not include blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    response = UserSearch.username_search("username", %{current_user: current_user})
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - does not include inverse blocked users", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:inverse_block_id_cache", context.spam_user.id])
    current_user = Network.User.preload_blocked_ids(context.current_user)

    response = UserSearch.username_search("username", %{current_user: current_user})
    assert to_string(context.user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    refute to_string(context.spam_user.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end

  test "username_search - lana test", context do
    Redis.command(["SADD", "user:#{context.current_user.id}:followed_users_id_cache", context.lana32d.id])

    response = UserSearch.username_search("lana", %{current_user: context.current_user})
    assert response.status_code == 200
    assert to_string(context.lana32d.id) == hd(Enum.map(response.body["hits"]["hits"], &(&1["_id"])))
    assert to_string(context.lanakane.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
    assert to_string(context.lanabandero.id) in Enum.map(response.body["hits"]["hits"], &(&1["_id"]))
  end
end
