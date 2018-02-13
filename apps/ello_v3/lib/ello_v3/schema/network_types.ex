defmodule Ello.V3.Schema.NetworkTypes do
  import Ello.V3.Schema.Helpers
  use Absinthe.Schema.Notation

  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
    field :settings, :user_settings
    field :user_stats, :user_stats, resolve: &source_self/2
    field :location, :string
    field :formatted_short_bio, :string
    field :badges, list_of(:string)
    field :external_links_list, list_of(:external_link), resolve: fn(_args, %{source: user}) ->
      {:ok, user.rendered_links}
    end
    field :avatar, :tshirt_image_versions, resolve: fn(_args, %{source: user}) ->
      {:ok, user.avatar_struct}
    end
    field :cover_image, :responsive_image_versions, resolve: fn(_args, %{source: user}) ->
      {:ok, user.cover_image_struct}
    end
    field :current_user_state, :user_current_user_state, resolve: &source_self/2
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
  end

  object :user_stats do
    field :followers_count, :integer
    field :following_count, :integer
    field :loves_count, :integer
    field :posts_count, :integer
    field :total_views_count, :integer
  end

  object :user_current_user_state do
    field :relationship_priority, :string, resolve: &relationship_priority/2
  end

  defp relationship_priority(_, %{source: %{id: id}, context: %{current_user: %{id: id}}}), do: {:ok, "self"}
  defp relationship_priority(_, %{source: %{relationship_to_current_user: nil}}), do: {:ok, nil}
  defp relationship_priority(_, %{source: %{relationship_to_current_user: %{priority: p}}}), do: {:ok, p}
  defp relationship_priority(_args, _resolution), do: {:ok, nil}
end
