defmodule Ello.Serve.Webapp.LoveView do
  use Ello.Serve.Web, :view
  alias Ello.Core.Network.User

  def render("meta.html", %{following: _, user: user} = assigns) do
    # assigns = assigns
    #           |> Map.put(:title, "Following | " <> User.title(user))
    #           |> Map.put(:description, "People following " <> User.title(user))
    #           |> Map.put(:robots, User.robots(user))
    #           |> Map.put(:image, user_image(user))
    render_template("meta.html", assigns)
  end
end
