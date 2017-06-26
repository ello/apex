defmodule Ello.Serve.Webapp.UserView do
  use Ello.Serve.Web, :view
  alias Ello.Core.Network.User
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("meta.html", %{user: user} = assigns) do
    assigns = assigns
              |> Map.put(:title, User.title(user))
              |> Map.put(:description, User.seo_description(user))
              |> Map.put(:robots, User.robots(user))
              |> Map.put(:image, image(user))
    render_template("meta.html", assigns)
  end

  def image(user) do
    version = Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized"))
    image_url(user.cover_image_struct.path, version.filename)
  end
end
