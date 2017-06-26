defmodule Ello.V2.UserMetaAttributesView do
  use Ello.V2.Web, :view
  alias Ello.Core.Network.User
  import Ello.V2.ImageView, only: [image_url: 2]

  def render("user.json", %{user: user}) do
    %{
      title: User.title(user),
      robots: User.robots(user),
      image: image(user),
      description: User.seo_description(user),
    }
  end

  defp image(user) do
    version = Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized"))
    image_url(user.cover_image_struct.path, version.filename)
  end
end
