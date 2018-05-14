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
    field :status, :string
    field :submitted_at, :datetime
    field :submitted_by, :user
    field :featured_at, :datetime
    field :featured_by, :user
    field :unfeatured_at, :datetime
    field :removed_at, :datetime
    field :category, :category
    field :actions, :category_post_actions, resolve: &actions/2
  end

  object :category_post_actions do
    field :feature, :category_post_action
    field :unfeature, :category_post_action
  end

  object :category_post_action do
    field :href, :string
    field :label, :string
    field :method, :string
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

  object :editorial_stream do
    field :next, :string
    field :per_page, :integer
    field :is_last_page, :boolean
    field :editorials, list_of(:editorial)
  end

  object :editorial do
    field :id, :id
    field :kind, :editorial_kind, resolve: &editorial_kind/2
    field :title, :string, resolve: &editorial_content/2
    field :subtitle, :string, resolve: &editorial_content(&1, &2, "rendered_subtitle")
    field :path, :string, resolve: &editorial_content(&1, &2)
    field :url, :string, resolve: &editorial_content(&1, &2)
    field :post, :post
    field :stream, :editorial_post_stream, resolve: &editorial_stream/2
    field :one_by_one_image, :responsive_image_versions, resolve: &editorial_image/2
    field :one_by_two_image, :responsive_image_versions, resolve: &editorial_image/2
    field :two_by_one_image, :responsive_image_versions, resolve: &editorial_image/2
    field :two_by_two_image, :responsive_image_versions, resolve: &editorial_image/2
  end

  enum :editorial_kind do
    value :post
    value :post_stream
    value :internal
    value :external
  end

  object :editorial_post_stream do
    field :query, :string
    field :tokens, list_of(:string)
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

  defp actions(args, %{context: %{current_user: nil}} = resolution) do
    actions(args, resolution, nil)
  end
  defp actions(args, %{source: category_post, context: %{current_user: current_user}} = resolution) do
    cat_user = Enum.find(current_user.category_users, &(&1.category_id == category_post.category.id))
    actions(args, resolution, cat_user)
  end
  defp actions(_, %{
    source: category_post,
    context: %{current_user: %{is_staff: true}},
  }, _) do
    {:ok, %{
      feature:   feature_action(category_post),
      unfeature: unfeature_action(category_post),
    }}
  end
  defp actions(_, %{source: category_post}, %{role: "curator"}) do
    {:ok, %{
      feature:   feature_action(category_post),
      unfeature: unfeature_action(category_post),
    }}
  end
  defp actions(_, _, _), do: {:ok, nil}

  defp feature_action(%{id: id, status: "submitted"}), do: %{
    href: "/api/v2/category_posts/#{id}/feature",
    method: "put",
  }
  defp feature_action(_), do: nil
  defp unfeature_action(%{id: id, status: "featured"}), do: %{
    href: "/api/v2/category_posts/#{id}/unfeature",
    method: "put",
  }
  defp unfeature_action(_), do: nil

  @editorial_kinds %{
    "post" => :post,
    "curated_posts" => :post_stream,
    "internal" => :internal,
    "external" => :external,
  }
  defp editorial_kind(_, %{source: %{kind: kind}}), do: {:ok, @editorial_kinds[kind]}

  defp editorial_content(a, b = %{definition: %{schema_node: %{identifier: name}}}),
    do: editorial_content(a, b, "#{name}")
  defp editorial_content(_, %{source: editorial}, key),
    do: {:ok, Map.get(editorial.content, key)}

  defp editorial_stream(_, %{source: %{kind: "curated_posts"} = editorial}) do
    {:ok, %{
      query: "findPosts",
      tokens: editorial.content["post_tokens"],
    }}
  end
  defp editorial_stream(_, _), do: {:ok, nil}

  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :one_by_one_image}},
    source: editorial,
  }), do: one_by_one_image(editorial)
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :one_by_two_image}},
    source: %{one_by_two_image_struct: nil} = editorial,
  }), do: one_by_one_image(editorial)
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :one_by_two_image}},
    source: %{one_by_two_image_struct: image},
  }), do: {:ok, image}
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :two_by_one_image}},
    source: %{two_by_one_image_struct: nil} = editorial,
  }), do: one_by_one_image(editorial)
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :two_by_one_image}},
    source: %{two_by_one_image_struct: image},
  }), do: {:ok, image}
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :two_by_two_image}},
    source: %{two_by_two_image_struct: nil} = editorial,
  }), do: one_by_one_image(editorial)
  defp editorial_image(_, %{
    definition: %{schema_node: %{identifier: :two_by_two_image}},
    source: %{two_by_two_image_struct: image},
  }), do: {:ok, image}

  defp one_by_one_image(%{one_by_one_image_struct: nil}), do: {:ok, %{}}
  defp one_by_one_image(%{one_by_one_image_struct: image}), do: {:ok, image}
end
