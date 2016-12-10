defmodule Ello.V2.UserView do
  use Ello.Web, :view
  alias Ello.V2.ImageView

  def render("user.json", %{user: user}) do
    %{
      id: "#{user.id}",
      href: "/api/v2/users/#{user.id}",
      username: user.username,
      name: user.name,
      location: user.location,
      posts_adult_content: user.settings.posts_adult_content,
      views_adult_content: user.settings.views_adult_content,
      has_commenting_enabled: user.settings.has_commenting_enabled,
      has_sharing_enabled: user.settings.has_sharing_enabled,
      has_reposting_enabled: user.settings.has_reposting_enabled,
      has_loves_enabled: user.settings.has_loves_enabled,
      has_auto_watch_enabled: user.settings.has_auto_watch_enabled,
      experimental_features: true,
      #relationship_priority: "self",
      bad_for_seo: user.bad_for_seo?,
      is_hireable: user.settings.is_hireable,
      is_collaborateable: user.settings.is_collaborateable,
      background_position: "50% 50%",
      avatar: render(ImageView, "image.json",
        model: user,
        attribute: :avatar
      ),
      cover_image: render(ImageView, "image.json",
        model: user,
        attribute: :cover_image
      ),
      links: %{
        categories: user.category_ids,
      }
    }
  end
end
