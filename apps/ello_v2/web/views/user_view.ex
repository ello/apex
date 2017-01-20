defmodule Ello.V2.UserView do
  use Ello.V2.Web, :view
  alias Ello.V2.{
    CategoryView,
    ImageView,
    LinkView,
  }

  def render("show.json", %{user: user, conn: conn}) do
    %{
      users: render_one(user, __MODULE__, "user.json", conn: conn),
      linked: %{
        categories: render_many(user.categories, CategoryView, "category.json", conn: conn),
      }
    }
  end

  @attributes [
    :username,
    :name,
    :location,
    :formatted_short_bio,
    :background_position,
    :followers_count,
    :following_count,
    :loves_count,
    :posts_count,
  ]

  @settings_attributes [
    :posts_adult_content,
    :views_adult_content,
    :has_commenting_enabled,
    :has_sharing_enabled,
    :has_reposting_enabled,
    :has_loves_enabled,
    :has_auto_watch_enabled,
    :is_hireable,
    :is_collaborateable,
  ]

  def render("user.json", %{user: user, conn: conn}) do
    user
    |> Map.take(@attributes)
    |> Map.merge(Map.take(user.settings, @settings_attributes))
    |> Map.merge(%{
      id: "#{user.id}",
      name: name(user, conn),
      href: "/api/v2/users/#{user.id}",
      experimental_features: experimental_features(user),
      relationship_priority: relationship(user, conn),
      bad_for_seo: user.bad_for_seo?,
      external_links_list: render(LinkView, "links.json", links: user.links),
      avatar: render(ImageView, "image.json", conn: conn, image: user.avatar_struct),
      cover_image: render(ImageView, "image.json", model: user, attribute: :cover_image),
      links: links(user, conn)
    })
  end

  def links(user, _conn) do
    %{
      categories: Enum.map(user.categories, &("#{&1.id}"))
    }
  end

  defp relationship(%{id: id}, %{assigns: %{current_user: %{id: id}}}), do: "self"
  defp relationship(%{relationship_to_current_user: nil}, _), do: nil
  defp relationship(%{relationship_to_current_user: %{priority: p}}, _), do: p
  defp relationship(_user, _conn), do: nil

  defp experimental_features(%{is_staff: true}), do: true
  defp experimental_features(%{has_experimental_features: true}), do: true
  defp experimental_features(_), do: false

  defp name(user, %{assigns: %{current_user: nil}}), do: user.name
  defp name(user, conn) do
    if blocked?(user, conn), do: "- blocked -", else: user.name
  end

  defp blocked?(_, %{assigns: %{current_user: nil}}), do: false
  defp blocked?(_, %{assigns: %{current_user: %{is_staff: true}}}), do: false
  defp blocked?(user, conn) do
    case relationship(user, conn) do
      "blocked" -> true
      _ -> false
    end
  end
end
