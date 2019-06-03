defmodule Ello.V2.ConditionalGetTest do
  use Ello.V2.ConnCase
  import Ello.V2.ConditionalGet, only: [etag: 1]

  setup do
    date = DateTime.utc_now
    {:ok, other_date} = date
                        |> DateTime.to_unix
                        |> Kernel.-(1)
                        |> DateTime.from_unix

    {:ok, date: date, other_date: other_date}
  end

  test "returns unique strings" do
    refute etag("testa") == etag("testb")
  end

  test "returns unique list strings" do
    lista = ["testa", "testa"]
    listb = ["testb", "testa"]
    listc = ["testa", "testa", "testa"]
    refute etag(lista) == etag(listb)
    refute etag(lista) == etag(listc)
  end

  test "returns etag of category", %{date: date, other_date: other_date} do
    category = Factory.build(:category, %{
      id: "123",
      updated_at: date,
      promotionals: Factory.build_list(2, :promotional, updated_at: DateTime.from_unix!(0)),
    })
    changes = [
      %{id: "124"},
      %{updated_at: other_date},
      %{promotionals: Factory.build_list(2, :promotional, updated_at: DateTime.from_unix!(1))}
    ]

    for change <- changes do
      new_category = Map.merge(category, change)
      refute etag(category) == etag(new_category), "changing " <> inspect(hd(Map.keys(change))) <> " doesn't change the etag"
    end
  end

  test "returns etag of user", %{date: date, other_date: other_date} do
    user = Factory.build(:user, %{
      id: "123",
      updated_at: date,
      posts_count: 2,
      loves_count: 3,
      followers_count: 4,
      following_count: 5,
      relationship_to_current_user: Factory.build(:relationship, %{priority: "friend"}),
    })
    changes = [
      %{id: "124"},
      %{updated_at: other_date},
      %{posts_count: user.posts_count + 10},
      %{loves_count: user.loves_count + 10},
      %{followers_count: user.followers_count + 10},
      %{following_count: user.following_count + 10},
      %{relationship_to_current_user: Factory.build(:relationship, %{priority: "mute"})},
      %{relationship_to_current_user: nil},
    ]

    for change <- changes do
      new_user = Map.merge(user, change)
      refute etag(user) == etag(new_user)
    end
  end

  test "returns etag of post", %{date: date, other_date: other_date} do
    post = Factory.build(:post, %{
      id: "123",
      updated_at: date,
      loves_count: 1,
      comments_count: 2,
      reposts_count: 3,
      author: Factory.build(:user, %{updated_at: date}),
    })
    changes = [
      %{id: "124"},
      %{updated_at: other_date},
      %{loves_count: post.loves_count + 10},
      %{comments_count: post.comments_count + 10},
      %{reposts_count: post.reposts_count + 10},
      %{author: Factory.build(:user, %{updated_at: other_date})},
    ]

    for change <- changes do
      new_post = Map.merge(post, change)
      refute etag(post) == etag(new_post)
    end
  end

end
