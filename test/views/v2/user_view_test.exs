defmodule Ello.V2.UserViewTest do
  use Ello.ConnCase, async: true
  import Phoenix.View #For render/2
  alias Ello.User
  alias Ello.V2.UserView

  test "user.json - it renders the user" do
    expected = %{
      id: "42",
      username: "archer",
    }
    assert render(UserView, "user.json", user: user1) == expected
  end

  def user1 do
    %User{
      id: 42,
      username: "archer"
    }
  end
end
