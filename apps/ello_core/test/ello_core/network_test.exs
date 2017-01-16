defmodule Ello.Core.NetworkTest do
  use Ello.Core.Case
  alias Ecto.Association.NotLoaded

  setup do
    current = Factory.insert(:user)
    {:ok,
      current:    current,
      friend1:    Factory.insert(:relationship,
                                 owner: current).subject,
      noise1:     Factory.insert(:relationship,
                                 owner: current,
                                 priority: "noise").subject,
      norelation: Factory.insert(:user),
    }
  end

  test "users/2 - with current user", context do
    user_ids = [context.friend1.id, context.noise1.id, context.norelation.id]
    Enum.each user_ids, fn(id) ->
      Redis.command(["SET", "user:#{id}:posts_counter", "11"])
      Redis.command(["SET", "user:#{id}:loves_counter", "12"])
    end

    assert [u1, u2, u3] = Network.users(user_ids, context.current)

    assert u1.posts_count == 11
    assert u1.loves_count == 12
    assert u1.relationship_to_current_user.priority == "friend"

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u2.relationship_to_current_user.priority == "noise"

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u3.relationship_to_current_user == nil

    Enum.each user_ids, fn(id) ->
      Redis.command(["DEL", "user:#{id}:posts_counter"])
      Redis.command(["DEL", "user:#{id}:loves_counter"])
    end
  end

  test "users/2 - without current user", context do
    user_ids = [context.friend1.id, context.noise1.id, context.norelation.id]
    Enum.each user_ids, fn(id) ->
      Redis.command(["SET", "user:#{id}:posts_counter", "11"])
      Redis.command(["SET", "user:#{id}:loves_counter", "12"])
    end

    assert [u1, u2, u3] = Network.users(user_ids)

    assert u1.posts_count == 11
    assert u1.loves_count == 12
    assert u1.relationship_to_current_user.__struct__ == NotLoaded

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u1.relationship_to_current_user.__struct__ == NotLoaded

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u1.relationship_to_current_user.__struct__ == NotLoaded

    Enum.each user_ids, fn(id) ->
      Redis.command(["DEL", "user:#{id}:posts_counter"])
      Redis.command(["DEL", "user:#{id}:loves_counter"])
    end
  end
end
