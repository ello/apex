defmodule Ello.Serve.Webapp.RelationshipView do
  use Ello.Serve.Web, :view
  import Ello.V2.ImageView, only: [image_url: 2]
  alias Ello.Core.Network.User

  def render("meta.html", %{following: _, user: user} = assigns) do
    assigns = assigns
              |> Map.put(:title, "Following | " <> User.title(user))
              |> Map.put(:description, "People following " <> User.title(user))
              |> Map.put(:robots, User.robots(user))
              |> Map.put(:image, user_image(user))
    render_template("meta.html", assigns)
  end

  def render("meta.html", %{followers: _, user: user} = assigns) do
    assigns = assigns
              |> Map.put(:title, "Followers | " <> User.title(user))
              |> Map.put(:description, "People followed by " <> User.title(user))
              |> Map.put(:robots, User.robots(user))
              |> Map.put(:image, user_image(user))
    render_template("meta.html", assigns)
  end

  def render("noscript.html", %{following: following, user: user} = assigns) do
    assigns = assigns
              |> Map.put(:relationships, following)
              |> Map.put(:relationship_type, "following")
              |> Map.put(:relationship_users, Enum.map(following, &(&1.subject)))
              |> Map.put(:user, user)
    render_template("noscript.html", assigns)
  end

  def render("noscript.html", %{followers: followers, user: user} = assigns) do
    assigns = assigns
              |> Map.put(:relationships, followers)
              |> Map.put(:relationship_type, "followers")
              |> Map.put(:relationship_users, Enum.map(followers, &(&1.owner)))
              |> Map.put(:user, user)
    render_template("noscript.html", assigns)
  end

  def user_image(user) do
    version = Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized"))
    image_url(user.cover_image_struct.path, version.filename)
  end

  def next_relationship_page_url(user, relationships, relationship_type) do
    webapp_url("#{user.username}/#{relationship_type}", before: List.last(relationships).created_at)
  end
end
