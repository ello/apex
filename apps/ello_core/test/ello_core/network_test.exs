defmodule Ello.Core.NetworkTest do
  use Ello.Core.Case
  alias Ecto.Association.NotLoaded
  alias Ello.Core.Image

  setup do
    current = Factory.insert(:user)
    category = Factory.insert(:category)
    {:ok,
      current:    current,
      category:   category,
      friend1:    Factory.insert(:relationship,
                                 owner: current).subject,
      noise1:     Factory.insert(:relationship,
                                 owner: current,
                                 priority: "noise").subject,
      norelation: Factory.insert(:user, category_ids: [category.id]),
    }
  end

  test "user/2 - without current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])

    assert %User{} = user = Network.user(user_id)

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.relationship_to_current_user.__struct__ == NotLoaded
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
  end

  test "user/2 - username- without current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])

    assert %User{} = user = Network.user("~#{context.friend1.username}")

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.relationship_to_current_user.__struct__ == NotLoaded
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
  end

  test "user/2 - with current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])

    assert %User{} = user = Network.user(user_id, context.current)

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.relationship_to_current_user.priority == "friend"
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
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
    assert u1.categories == []

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u2.relationship_to_current_user.priority == "noise"
    assert u2.categories == []

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u3.relationship_to_current_user == nil
    assert context.category.id in Enum.map(u3.categories, &(&1.id))
    assert %Image{} = u3.avatar_struct
    assert %Image{} = u3.cover_image_struct

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
    assert u1.categories == []
    assert %Image{} = u1.avatar_struct
    assert %Image{} = u1.cover_image_struct

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u2.relationship_to_current_user.__struct__ == NotLoaded
    assert u2.categories == []

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u3.relationship_to_current_user.__struct__ == NotLoaded
    assert context.category.id in Enum.map(u3.categories, &(&1.id))

    Enum.each user_ids, fn(id) ->
      Redis.command(["DEL", "user:#{id}:posts_counter"])
      Redis.command(["DEL", "user:#{id}:loves_counter"])
    end
  end
end
