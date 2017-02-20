defmodule Ello.V2.UserMetaAttributesViewTest do
  use Ello.V2.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.V2.UserMetaAttributesView

  setup %{conn: conn} do
    archer = Script.build(:archer)
    {:ok, conn: conn, user: archer}
  end

  test "user.json - it renders meta attributes for a user", %{user: user} do
    assert %{
      description: "I have been spying for a while now",
      image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
      robots: "index, follow",
      title: "Sterling Archer (@archer) | Ello",
    } == render(UserMetaAttributesView, "user.json", user: user)
  end

  test "user.json - renders the title correctly if the user has no name", %{user: user} do
    user = Map.put(user, :name, nil)
    assert %{
      description: "I have been spying for a while now",
      image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
      robots: "index, follow",
      title: "@archer | Ello",
    } == render(UserMetaAttributesView, "user.json", user: user)
  end

  test "user.json - renders the robots correctly if the user is bad for seo", %{user: user} do
    user = Map.put(user, :bad_for_seo, true)
    assert %{
      description: "I have been spying for a while now",
      image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
      robots: "noindex, follow",
      title: "Sterling Archer (@archer) | Ello",
    } == render(UserMetaAttributesView, "user.json", user: user)
  end

  test "user.json - renders the description correctly if the user has no bio", %{user: user} do
    user = Map.put(user, :formatted_short_bio, nil)
    assert %{
      description: "See Sterling Archer's work on Ello",
      image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
      robots: "index, follow",
      title: "Sterling Archer (@archer) | Ello",
    } == render(UserMetaAttributesView, "user.json", user: user)
  end

  test "user.json - renders the description correctly if the user has no bio and no name", %{user: user} do
    user = user
           |> Map.put(:formatted_short_bio, nil)
           |> Map.put(:name, nil)
    assert %{
      description: "See @archer's work on Ello",
      image: "https://assets.ello.co/uploads/user/cover_image/42/ello-optimized-061fb4e4.jpg",
      robots: "index, follow",
      title: "@archer | Ello",
    } == render(UserMetaAttributesView, "user.json", user: user)
  end
end
