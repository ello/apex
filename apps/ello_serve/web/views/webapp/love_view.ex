defmodule Ello.Serve.Webapp.LoveView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Core.Network.User

  def render("meta.html", %{loves: _, user: user} = assigns) do
    assigns = assigns
              |> Map.put(:title, "Posts loved by " <> User.title(user))
              |> Map.put(:description, "Posts loved by " <> User.title(user))
              |> Map.put(:robots, User.robots(user))
              |> Map.put(:image, user_image(user))
    render_template("meta.html", assigns)
  end

  def render("noscript.html", %{loves: loves} = assigns) do
    assigns = assigns
              |> Map.put(:loves, loves)
              |> Map.put(:loved_posts, Enum.map(loves, &(&1.post)))
    render_template("noscript.html", assigns)
  end

  def user_image(user) do
    version = Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized"))
    image_url(user.cover_image_struct.path, version.filename)
  end

  def next_love_page_url(user, loves) do
    before = loves
             |> List.last
             |> Map.get(:created_at)
             |> DateTime.to_iso8601
    webapp_url("#{user.username}/loves", before: before)
  end
end
