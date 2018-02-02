defmodule Ello.V3.Schema.DiscoveryTypes do
  use Absinthe.Schema.Notation

  object :category do
    field :id, :id
    field :slug, :string
    field :roshi_slug, :string
    field :level, :string
    field :order, :integer
    field :tile_image, :tshirt_image_versions, resolve: fn(_args, %{source: category}) ->
      {:ok, category.tile_image_struct}
    end
    field :allow_in_onboarding, :boolean
    field :description, :string
    field :is_sponsored, :boolean
    field :header, :string
    field :cta_caption, :string
    field :cta_href, :string
    field :uses_page_promotionals, :boolean
    field :is_creator_type, :boolean
    field :created_at, :datetime
    field :promotionals, list_of(:promotional), resolve: fn(_args, %{source: promotional}) ->
      {:ok, promotional.image_struct}
    end
 reso
  end

  object :promotional do
    field :user, :user
    field :post_token, :string
    field :created_at, :datetime
    field :image, :responsive_image_versions, resolve: fn(_args, %{source: promotional}) ->
      {:ok, promotional.image_struct}
    end
  end
end
