defmodule Ello.V3.Schema.NetworkTypes do
  import Ello.V3.Schema.Helpers
  use Absinthe.Schema.Notation
  alias Ello.V3.Resolvers
  alias Ello.Core.Network.User

  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
    field :settings, :user_settings
    field :user_stats, :user_stats, resolve: &source_self/2
    field :location, :string
    field :formatted_short_bio, :string
    field :badges, list_of(:string), resolve: &user_badges/2
    field :experimental_features, :boolean, resolve: &experimental_features/2
    field :is_community, :boolean
    field :external_links_list, list_of(:external_link), resolve: &external_links_list/2
    field :avatar, :tshirt_image_versions, resolve: &avatar_struct/2
    field :cover_image, :responsive_image_versions, resolve: &cover_image_struct/2
    field :current_user_state, :user_current_user_state, resolve: &source_self/2
    field :category_users, list_of(:category_user) do
      arg :roles, list_of(:category_user_role)
      resolve &Resolvers.CategoryUsers.call/3
    end
    field :meta_attributes, :user_meta_attributes, resolve: &user_meta/2
  end

  object :user_stream do
    field :next, :string
    field :per_page, :integer
    field :is_last_page, :boolean
    field :users, list_of(:user)
  end

  object :profile do
    field :name, :string
    field :username, :string
    field :email, :string
    field :location, :string
    field :formatted_short_bio, :string
    field :short_bio, :string
    field :web_onboarding_version, :string
    field :allows_analytics, :boolean, resolve: &user_profile/2
    field :discoverable, :boolean, resolve: &user_profile/2
    field :has_ad_notifications_enabled, :boolean, resolve: &user_profile/2
    field :has_announcements_enabled, :boolean, resolve: &user_profile/2
    field :has_auto_watch_enabled, :boolean, resolve: &user_profile/2
    field :has_reposting_enabled, :boolean, resolve: &user_profile/2
    field :has_sharing_enabled, :boolean, resolve: &user_profile/2
    field :is_collaborateable, :boolean, resolve: &user_profile/2
    field :is_hireable, :boolean, resolve: &user_profile/2
    field :is_brand, :boolean, resolve: &user_profile/2
    field :notify_of_announcements_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_approved_submissions_from_following_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_approved_submissions_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_featured_category_post_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_featured_category_post_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_approved_submissions_from_following_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_comments_on_post_watch_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_comments_on_post_watch_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_comments_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_comments_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_invitation_acceptances_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_invitation_acceptances_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_loves_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_loves_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_mentions_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_mentions_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_new_followers_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_new_followers_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_reposts_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_reposts_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_watches_via_email, :boolean, resolve: &user_profile/2
    field :notify_of_watches_via_push, :boolean, resolve: &user_profile/2
    field :notify_of_what_you_missed_via_email, :boolean, resolve: &user_profile/2
    field :subscribe_to_daily_ello, :boolean, resolve: &user_profile/2
    field :subscribe_to_onboarding_drip, :boolean, resolve: &user_profile/2
    field :subscribe_to_users_email_list, :boolean, resolve: &user_profile/2
    field :subscribe_to_weekly_ello, :boolean, resolve: &user_profile/2
  end

  object :external_link do
    field :icon, :string
    field :type, :string
    field :text, :string
    field :url, :string
  end

  object :user_settings do
    field :posts_adult_content, :boolean
    field :has_commenting_enabled, :boolean
    field :has_reposting_enabled, :boolean
    field :has_sharing_enabled, :boolean
    field :has_loves_enabled, :boolean
    field :is_collaborateable, :boolean
    field :is_hireable, :boolean
    field :is_brand, :boolean
  end

  object :user_stats do
    field :followers_count, :integer
    field :following_count, :integer
    field :loves_count, :integer
    field :posts_count, :integer
    field :total_views_count, :integer
  end

  object :user_meta_attributes do
    field :title, :string
    field :robots, :string
    field :image, :string
    field :description, :string
  end

  object :user_current_user_state do
    field :relationship_priority, :string, resolve: &relationship_priority/2
  end

  enum :relationship_kind do
    value :following
    value :followers
  end

  object :user_stream do
    field :users, list_of(:user)
    field :next, :string
    field :per_page, :integer
    field :is_last_page, :boolean
  end

  defp relationship_priority(_, %{source: %{id: id}, context: %{current_user: %{id: id}}}), do: {:ok, "self"}
  defp relationship_priority(_, %{source: %{relationship_to_current_user: %{priority: p}}}), do: {:ok, p}
  defp relationship_priority(_args, _resolution), do: {:ok, nil}

  defp experimental_features(_, %{source: %{is_staff: true}}), do: {:ok, true}
  defp experimental_features(_, %{source: %{has_experimental_features: true}}), do: {:ok, true}
  defp experimental_features(_, _), do: {:ok, false}


  defp user_meta(_, %{source: user}) do
    {:ok, %{
      title: User.title(user),
      robots: User.robots(user),
      image: image(user),
      description: User.seo_description(user),
    }}
  end

  defp user_profile(_, %{source: user, definition: %{schema_node: %{identifier: name}}}) do
    {:ok, Map.get(user.settings, name)}
  end

  defp image(user) do
    version = Enum.find(user.cover_image_struct.versions, &(&1.name == "optimized"))
    image_url(user.cover_image_struct.path, version.filename)
  end


  defp external_links_list(_args, %{source: %{rendered_links: nil}}), do: {:ok, []}
  defp external_links_list(_args, %{source: %{rendered_links: rendered_links}}) do
    rendered_links_as_atoms = rendered_links |> Enum.map(fn(link) ->
      for {key, val} <- link, into: %{}, do: {
        (if is_atom(key), do: key, else: String.to_atom(key)),
        val
      }
    end)
    {:ok, rendered_links_as_atoms}
  end
  defp external_links_list(_args, _), do: {:ok, nil}

  defp avatar_struct(_args, %{source: %{avatar_struct: avatar_struct}}) do
    {:ok, avatar_struct}
  end
  defp avatar_struct(_args, _), do: {:ok, nil}

  defp cover_image_struct(_args, %{source: %{cover_image_struct: cover_image_struct}}) do
    {:ok, cover_image_struct}
  end
  defp cover_image_struct(_args, _), do: {:ok, nil}


  @sensitive_badges [
    "nsfw",
    "spam",
  ]

  defp user_badges(_, %{source: %{badges: nil}}), do: {:ok, []}
  defp user_badges(_, %{source: %{badges: []}}), do: {:ok, []}
  defp user_badges(_, %{source: %{badges: badges}, context: %{current_user: %{is_staff: true}}}),
    do: {:ok, badges}
  defp user_badges(_, %{source: %{badges: badges}}),
    do: {:ok, Enum.reject(badges, &(Enum.member?(@sensitive_badges, &1)))}
end
