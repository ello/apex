defmodule Ello.V3.Schema.NetworkTypes do
  import Ello.V3.Schema.Helpers
  use Absinthe.Schema.Notation

  # Flags
  # Settings
  object :user do
    field :id, :id
    field :username, :string
    field :name, :string
    field :posts_adult_content, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.posts_adult_content}
    end
    field :has_commenting_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_commenting_enabled}
    end
    field :has_reposting_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_reposting_enabled}
    end
    field :has_sharing_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_sharing_enabled}
    end
    field :has_loves_enabled, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.has_loves_enabled}
    end
    field :is_collaborateable, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.is_collaborateable}
    end
    field :is_hireable, :boolean, resolve: fn(_args, %{source: user}) ->
      {:ok, user.settings.is_hireable}
    end
    field :avatar, :avatar, resolve: fn(_args, %{source: user}) ->
      {:ok, user.avatar_struct}
    end
    field :cover_image, :cover_image, resolve: fn(_args, %{source: user}) ->
      {:ok, user.cover_image_struct}
    end

    # field :relationship_priority, :string
  end

  object :avatar do
    field :small, :image, resolve: &resolve_image/2
    field :regular, :image, resolve: &resolve_image/2
    field :large, :image, resolve: &resolve_image/2
    field :original, :image, resolve: &resolve_image/2
  end

  object :cover_image do
    field :hdpi, :image, resolve: &resolve_image/2
    field :ldpi, :image, resolve: &resolve_image/2
    field :mdpi, :image, resolve: &resolve_image/2
    field :xhdpi, :image, resolve: &resolve_image/2
    field :original, :image, resolve: &resolve_image/2
    field :optimized, :image, resolve: &resolve_image/2
  end

end
