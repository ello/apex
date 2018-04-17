defmodule Ello.V3.Schema.DiscoveryTypes do
  use Absinthe.Schema.Notation

  object :category do
    field :id, :id
    field :name, :string
    field :slug, :string
    field :level, :string
    field :order, :integer
    field :tile_image, :tshirt_image_versions, resolve: fn(_args, %{source: category}) ->
      {:ok, category.tile_image_struct}
    end
    field :allow_in_onboarding, :boolean
    field :is_creator_type, :boolean
    field :created_at, :datetime
  end

  object :category_post do
    field :id, :id
    field :status, :string, resolve: &category_post_status/2
    field :submitted_at, :datetime
    field :submitted_by, :user
    field :featured_at, :datetime
    field :featured_by, :user
    field :unfeatured_at, :datetime
    field :removed_at, :datetime
    field :category, :category
  end

  object :page_header do
    field :id, :id
    field :user, :user
    field :post_token, :string
    field :slug, :string, resolve: &page_header_slug/2
    field :kind, :page_header_kind, resolve: &page_header_kind/2
    field :header, :string, resolve: &page_header_header/2
    field :subheader, :string, resolve: &page_header_sub_header/2
    field :cta_link, :page_header_cta_link, resolve: &page_header_cta_link/2
    field :image, :responsive_image_versions, resolve: &page_header_image/2
    field :category, :category
  end

  enum :page_header_kind do
    value :category
    value :artist_invite
    value :editorial
    value :authentication
    value :generic
  end

  object :page_header_cta_link do
    field :text, :string
    field :url, :string
  end

  defp page_header_kind(_, %{source: %{category_id: _}}), do: {:ok, :category}
  defp page_header_kind(_, %{source: %{is_editorial: true}}), do: {:ok, :editorial}
  defp page_header_kind(_, %{source: %{is_artist_invite: true}}), do: {:ok, :artist_invite}
  defp page_header_kind(_, %{source: %{is_authentication: true}}), do: {:ok, :authentication}
  defp page_header_kind(_, %{source: _}), do: {:ok, :generic}

  defp page_header_slug(_, %{source: %{category: %{slug: slug}}}), do: {:ok, slug}
  defp page_header_slug(_, %{source: _}), do: {:ok, nil}

  defp page_header_header(_, %{source: %{category: %{header: nil, name: copy}}}), do: {:ok, copy}
  defp page_header_header(_, %{source: %{category: %{header: copy}}}), do: {:ok, copy}
  defp page_header_header(_, %{source: %{header: copy}}), do: {:ok, copy}

  defp page_header_sub_header(_, %{source: %{category: %{description: copy}}}), do: {:ok, copy}
  defp page_header_sub_header(_, %{source: %{subheader: copy}}), do: {:ok, copy}

  defp page_header_cta_link(_, %{source: %{category: %{cta_caption: text, cta_href: url}}}),
    do: {:ok, %{text: text, url: url}}
  defp page_header_cta_link(_, %{source: %{cta_caption: text, cta_href: url}}),
    do: {:ok, %{text: text, url: url}}

  defp page_header_image(_, %{source: %{image_struct: image}}), do: {:ok, image}

  def category_post_status(_, %{source: %{removed_at: nil, featured_at: nil}}),
    do: {:ok, "submitted"}
  def category_post_status(_, %{source: %{removed_at: nil, unfeatured_at: nil}}),
    do: {:ok, "featured"}
  def category_post_status(_, %{source: %{submitted_at: submitted, removed_at: removed}})
    when submitted > removed,
    do: {:ok, "submitted"}
  def category_post_status(_, %{source: %{featured_at: featured, unfeatured_at: unfeatured}})
    when featured > unfeatured,
    do: {:ok, "featured"}
  def category_post_status(_, %{source: %{removed_at: %{}}}),
    do: {:ok, "removed"}
  def category_post_status(_, _),
    do: {:ok, "submitted"}
end
