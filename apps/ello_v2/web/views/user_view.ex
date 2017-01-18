defmodule Ello.V2.UserView do
  use Ello.V2.Web, :view
  alias Ello.V2.ImageView
  alias Ello.V2.LinkView

  @lint false
  def render("user.json", %{user: user, conn: conn}) do
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
      relationship_priority: relationship(user, conn),
      bad_for_seo: user.bad_for_seo?,
      is_hireable: user.settings.is_hireable,
      is_collaborateable: user.settings.is_collaborateable,
      background_position: "50% 50%",
      followers_count: user.followers_count,
      following_count: user.following_count,
      loves_count: user.loves_count,
      posts_count: user.posts_count,
      external_links_list: render(LinkView, "links.json", %{links: user.links}),
      avatar: render(ImageView, "image.json", model: user, attribute: :avatar),
      cover_image: render(ImageView, "image.json", model: user, attribute: :cover_image),
      links: %{categories: user.category_ids}
    }
  end

  defp relationship(%{id: id}, %{assigns: %{current_user: %{id: id}}}), do: "self"
  defp relationship(%{relationship_to_current_user: nil}, _), do: nil
  defp relationship(%{relationship_to_current_user: %{priority: p}}, _), do: p
  defp relationship(_user, _conn), do: nil
end
