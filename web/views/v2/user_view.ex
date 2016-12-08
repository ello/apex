defmodule Ello.V2.UserView do
  use Ello.Web, :view

  def render("user.json", %{user: user}) do
    %{
      id: "#{user.id}",
      username: user.username,
    }
  end
end
