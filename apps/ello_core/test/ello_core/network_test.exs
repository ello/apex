defmodule Ello.Core.NetworkTest do
  use Ello.Core.Case
  alias Ecto.Association.NotLoaded
  alias Ello.Core.Image

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    current = Factory.insert(:user)
    category = Factory.insert(:category)
    norelation = Factory.insert(:user)
    Factory.insert(:category_user, user: norelation, category: category)
    {:ok,
      current:    current,
      category:   category,
      friend1:    Factory.insert(:relationship,
                                 owner: current).subject,
      noise1:     Factory.insert(:relationship,
                                 owner: current,
                                 priority: "noise").subject,
      norelation: norelation,
    }
  end

  test "user/2 - without current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])
    Redis.command(["SET", "user:#{user_id}:total_post_views_counter", "13"])

    assert %User{} = user = Network.user(%{id_or_username: user_id})

    Redis.command(["DEL", "user:#{user_id}:posts_counter"])
    Redis.command(["DEL", "user:#{user_id}:loves_counter"])
    Redis.command(["DEL", "user:#{user_id}:total_post_views_counter"])

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.total_views_count == 13
    assert user.relationship_to_current_user.__struct__ == NotLoaded
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
  end

  test "user/2 - system user" do
    system = Factory.insert(:user, is_system_user: true)
    Redis.command(["SET", "user:#{system.id}:followed_users_counter", "11"])
    Redis.command(["SET", "user:#{system.id}:followers_counter", "12"])
    Redis.command(["SET", "user:#{system.id}:loves_counter", "12"])
    Redis.command(["SET", "user:#{system.id}:total_post_views_counter", "13"])

    assert %User{} = user = Network.user(%{id_or_username: system.id})

    Redis.command(["DEL", "user:#{system.id}:followed_users_counter"])
    Redis.command(["DEL", "user:#{system.id}:followers_counter"])
    Redis.command(["DEL", "user:#{system.id}:loves_counter"])
    Redis.command(["DEL", "user:#{system.id}:total_post_views_counter"])

    assert user.followers_count == 0
    assert user.following_count == 0
    assert user.loves_count == 12
    assert user.total_views_count == 13
  end

  test "user/2 - username- without current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])
    Redis.command(["SET", "user:#{user_id}:total_post_views_counter", "13"])

    assert %User{} = user = Network.user(%{id_or_username: "~#{context.friend1.username}"})

    Redis.command(["DEL", "user:#{user_id}:posts_counter"])
    Redis.command(["DEL", "user:#{user_id}:loves_counter"])
    Redis.command(["DEL", "user:#{user_id}:total_post_views_counter"])

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.total_views_count == 13
    assert user.relationship_to_current_user.__struct__ == NotLoaded
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
  end

  test "user/2 - with current user", context do
    user_id = context.friend1.id
    Redis.command(["SET", "user:#{user_id}:posts_counter", "11"])
    Redis.command(["SET", "user:#{user_id}:loves_counter", "12"])
    Redis.command(["SET", "user:#{user_id}:total_post_views_counter", "13"])

    assert %User{} = user = Network.user(%{
      id_or_username: user_id,
      current_user:   context.current
    })

    Redis.command(["DEL", "user:#{user_id}:posts_counter"])
    Redis.command(["DEL", "user:#{user_id}:loves_counter"])
    Redis.command(["DEL", "user:#{user_id}:total_post_views_counter"])

    assert user.posts_count == 11
    assert user.loves_count == 12
    assert user.total_views_count == 13
    assert user.relationship_to_current_user.priority == "friend"
    assert %Image{} = user.avatar_struct
    assert %Image{} = user.cover_image_struct
  end

  test "users/2 - with current user", context do
    user_ids = [context.friend1.id, context.noise1.id, context.norelation.id]
    Enum.each user_ids, fn(id) ->
      Redis.command(["SET", "user:#{id}:posts_counter", "11"])
      Redis.command(["SET", "user:#{id}:loves_counter", "12"])
      Redis.command(["SET", "user:#{id}:total_post_views_counter", "13"])
    end

    assert [u1, u2, u3] = Network.users(%{
      ids: user_ids,
      current_user: context.current
    })

    assert u1.posts_count == 11
    assert u1.loves_count == 12
    assert u1.total_views_count == 13
    assert u1.relationship_to_current_user.priority == "friend"
    assert u1.categories == []

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u2.total_views_count == 13
    assert u2.relationship_to_current_user.priority == "noise"
    assert u2.categories == []

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u3.total_views_count == 13
    assert u3.relationship_to_current_user == nil
    assert context.category.id in Enum.map(u3.categories, &(&1.id))
    assert %Image{} = u3.avatar_struct
    assert %Image{} = u3.cover_image_struct

    Enum.each user_ids, fn(id) ->
      Redis.command(["DEL", "user:#{id}:posts_counter"])
      Redis.command(["DEL", "user:#{id}:loves_counter"])
      Redis.command(["DEL", "user:#{id}:total_post_views_counter"])
    end
  end

  test "users/2 - without current user", context do
    user_ids = [context.friend1.id, context.noise1.id, context.norelation.id]
    Enum.each user_ids, fn(id) ->
      Redis.command(["SET", "user:#{id}:posts_counter", "11"])
      Redis.command(["SET", "user:#{id}:loves_counter", "12"])
      Redis.command(["SET", "user:#{id}:total_post_views_counter", "13"])
    end

    assert [u1, u2, u3] = Network.users(%{ids: user_ids})

    assert u1.posts_count == 11
    assert u1.loves_count == 12
    assert u1.total_views_count == 13
    assert u1.relationship_to_current_user.__struct__ == NotLoaded
    assert u1.categories == []
    assert %Image{} = u1.avatar_struct
    assert %Image{} = u1.cover_image_struct

    assert u2.posts_count == 11
    assert u2.loves_count == 12
    assert u2.total_views_count == 13
    assert u2.relationship_to_current_user.__struct__ == NotLoaded
    assert u2.categories == []

    assert u3.posts_count == 11
    assert u3.loves_count == 12
    assert u3.total_views_count == 13
    assert u3.relationship_to_current_user.__struct__ == NotLoaded
    assert context.category.id in Enum.map(u3.categories, &(&1.id))

    Enum.each user_ids, fn(id) ->
      Redis.command(["DEL", "user:#{id}:posts_counter"])
      Redis.command(["DEL", "user:#{id}:loves_counter"])
      Redis.command(["DEL", "user:#{id}:total_post_views_counter"])
    end
  end

  test "users/2 - get followers" do
    followed = Factory.insert(:user)
    f1 = Factory.insert(:relationship,
     subject:    followed,
     created_at: DateTime.from_unix!(1_000_000)
    ).owner
    f2 = Factory.insert(:relationship,
     subject:    followed,
     created_at: DateTime.from_unix!(2_000_000)
    ).owner
    f3 = Factory.insert(:relationship,
     subject:    followed,
     created_at: DateTime.from_unix!(3_000_000)
    ).owner
    f4 = Factory.insert(:relationship,
     subject:    followed,
     created_at: DateTime.from_unix!(4_000_000)
    ).owner

    assert [r1, r2] = Network.relationships(%{followers: followed, per_page: 2})
    assert [f4.id, f3.id] == [r1.owner.id, r2.owner.id]

    assert [r3, r4] = Network.relationships(%{followers: followed, per_page: 2, before: r2.created_at})
    assert [f2.id, f1.id] == [r3.owner.id, r4.owner.id]
  end

  test "users/2 - get following" do
    follower = Factory.insert(:user)
    _f1 = Factory.insert(:relationship,
     owner:      follower,
     created_at: DateTime.from_unix!(1_000_000)
    ).subject
    _f2 = Factory.insert(:relationship,
     owner:      follower,
     created_at: DateTime.from_unix!(2_000_000)
    ).subject
    f3 = Factory.insert(:relationship,
     owner:      follower,
     created_at: DateTime.from_unix!(3_000_000)
    ).subject
    f4 = Factory.insert(:relationship,
     owner:      follower,
     created_at: DateTime.from_unix!(4_000_000)
    ).subject

    assert [r1, r2] = Network.relationships(%{following: follower, per_page: 2})
    assert [f4.id, f3.id] == [r1.subject.id, r2.subject.id]
  end

  test "following_ids/1 - returns folling user ids", %{current: current} do
    redis_key = "user:#{current.id}:followed_users_id_cache"
    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
    user3 = Factory.insert(:user)
    user_ids = [user1.id, user2.id, user3.id]
    for id <- user_ids do
      Redis.command(["SADD", redis_key, id])
    end
    following_ids = Network.following_ids(current)
    Redis.command(["DEL", redis_key])

    assert Enum.member?(following_ids, "#{user1.id}")
    assert Enum.member?(following_ids, "#{user2.id}")
    assert Enum.member?(following_ids, "#{user3.id}")
  end
end
