defmodule Ello.V2.UserView do
  use Ello.V2.Web, :view
  use Ello.V2.JSONAPI
  alias Ello.V2.{
    CategoryView,
    ImageView,
    UserMetaAttributesView,
  }

  def stale_checks(_, %{data: user}) do
    [etag: etag(user)]
  end

  @doc "Render user and relations for /api/v2/users/:id"
  def render("show.json", %{data: user} = opts) do
    json_response()
    |> render_resource(:users, user, __MODULE__, Map.merge(opts, %{meta: true}))
    |> include_linked(:categories, user.categories, CategoryView, opts)
  end

  @doc "Render a single user as included in other reponses"
  def render("user.json", %{user: user} = opts) do
    user
    |> render_self(__MODULE__, opts)
    |> add_meta(user, opts[:meta])
    |> settings_attributes(user)
  end

  def attributes, do: [
    :username,
    :name,
    :location,
    :formatted_short_bio,
    :followers_count,
    :following_count,
    :loves_count,
    :posts_count,
  ]

  def computed_attributes, do: [
    :name,
    :href,
    :experimental_features,
    :relationship_priority,
    :bad_for_seo,
    :external_links_list,
    :avatar,
    :cover_image,
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

  defp add_meta(resp, user, true) do
    Map.put(resp, :meta_attributes, render(UserMetaAttributesView, "user.json", user: user))
  end
  defp add_meta(resp, _, _), do: resp

  defp settings_attributes(resp, user) do
    user.settings
    |> Map.take(@settings_attributes)
    |> Map.merge(resp)
  end

  def links(user, _conn) do
    %{
      categories: Enum.map(user.categories, &("#{&1.id}"))
    }
  end

  def href(%{id: id}, _conn), do: "/api/v2/users/#{id}"

  def relationship_priority(%{id: id}, %{assigns: %{current_user: %{id: id}}}), do: "self"
  def relationship_priority(%{relationship_to_current_user: nil}, _), do: nil
  def relationship_priority(%{relationship_to_current_user: %{priority: p}}, _), do: p
  def relationship_priority(_user, _conn), do: nil

  def experimental_features(%{is_staff: true}, _), do: true
  def experimental_features(%{has_experimental_features: true}, _), do: true
  def experimental_features(_, _), do: false

  def external_links_list(%{rendered_links: links}, _conn), do: links

  def avatar(user, conn),
    do: render(ImageView, "image.json", conn: conn, image: user.avatar_struct)

  def cover_image(user, conn),
    do: render(ImageView, "image.json", conn: conn, image: user.cover_image_struct)

  def name(user, %{assigns: %{current_user: nil}}), do: user.name
  def name(user, conn) do
    if blocked?(user, conn), do: "- blocked -", else: user.name
  end

  def bad_for_seo(%{bad_for_seo?: bad_for_seo}, _), do: bad_for_seo

  def blocked?(_, %{assigns: %{current_user: nil}}), do: false
  def blocked?(_, %{assigns: %{current_user: %{is_staff: true}}}), do: false
  def blocked?(user, conn) do
    case relationship_priority(user, conn) do
      "blocked" -> true
      _ -> false
    end
  end
end
