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

  def cover_image_url(user), do: image(user)

  def avatar_url(user) do
    version = Enum.find(user.avatar_struct.versions, &(&1.name == "regular"))
    image_url(user.avatar_struct.path, version.filename)
  end

  def next_post_page_url(user, posts_page) do
    webapp_url(user.username, before: DateTime.to_iso8601(posts_page.before))
  end
end
