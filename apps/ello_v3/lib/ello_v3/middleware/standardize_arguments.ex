defmodule Ello.V3.Middleware.StandardizeArguments do
  alias Absinthe.Blueprint.Document.{
    Fragment,
  }
  @moduledoc """
  Middleware that injects our standard args based on user client and settings.

  Every query resolver will now get, in addition to custom arguments:
    * current_user
    * allow_nsfw
    * allow_nudity
    * per_page (maxed at 100)
    * page
    * before

  """
  @max_page_size 100
  @default_page_size 25

  def call(%{context: context, arguments: args} = resolution, _) do
    Map.put(resolution, :arguments, Map.merge(args, %{
      current_user: context[:current_user],
      allow_nsfw:   context[:allow_nsfw],
      allow_nudity: context[:allow_nudity],
      before:       before(args),
      per_page:     per_page(args),
      page:         page(args),
      preloads:     preloads(resolution),
    }))
  end

  defp before(%{before: before}), do: before
  defp before(_), do: nil

  defp page(%{page: nil}), do: 1
  defp page(%{page: page}), do: page
  defp page(_), do: 1

  defp per_page(%{per_page: nil}), do: @default_page_size
  defp per_page(%{per_page: per_page}) when per_page > @max_page_size, do: @max_page_size
  defp per_page(%{per_page: per_page}), do: per_page
  defp per_page(_), do: @default_page_size


  # Root and query types are dropped so we just get a list of the preloads
  @root_fields [:post, :posts, :page_headers, :editorials, :category, :categories, :comments,
                :loves, :users]
  @query_types [:post_stream, :category_post_stream, :editorial_stream, :category_nav, :find_posts,
                :find_user, :comment_stream, :love_stream, :search_categories, :search_users,
                :all_categories]

  # Ignores fields are typically nested json we just don't need to add to the preloads.
  @ignore_fields [
    :cover_image, :avatar, :external_links_list, # User
    :attachment, :repost_content, :summary, :content, # Post/Assets
    :tile_image, # Category
    :cta_link, :image, # Promotionals/PagePromotional
  ]

  @doc """
  Takes an Absinthe.Resolution parses the query AST and returns a map of preloads.

  The AST representation of the GraphQL query built by Absinth is split into 2 parts.
  The definition is the root type, such as "post_stream", the fragments are a map fragments
  included in the query keyed by name.

  The definintion is a deeply nested structure of reflecting the query, but with additional
  server side data built in.

  Preloads recursively parses that nested data structure and adds any items with children as map keys.
  When a "Fragment.Spread" is encountered the fragment is grabbed from the keys fragments hash and
  its selections are added directly to the current level.
  """
  def preloads(%{definition: field, fragments: fragments}) do
    field
    |> strip_query
    |> strip_root(fragments)
    |> find_preloads(fragments, %{})
  end

  # Ignore top level query types - they are not part of the pre-load tree we need
  defp strip_query(%{schema_node: %{type: t}, selections: s}) when t in @query_types,
    do: s
  defp strip_query(%{schema_node: %{identifier: i}, selections: s}) when i in @query_types,
    do: s
  defp strip_query(field), do: field

  # Ignore top level data types - this is a convienience so we don't have to grab a specific key
  # in the top level.
  defp strip_root(fields, fragments) when is_list(fields),
    do: Enum.reduce(fields, [], &([strip_root(&1, fragments) | &2]))
  defp strip_root(%{schema_node: %{identifier: f}, selections: children}, _) when f in @root_fields,
    do: children
  defp strip_root(%Fragment.Spread{} = spread, fragments) do
    strip_root(Map.get(fragments, spread.name).selections, fragments)
  end
  defp strip_root(field, _), do: field

  defp find_preloads(%{selections: []}, _fragments, preloads) do
    preloads
  end
  defp find_preloads(selections, fragments, preloads) when is_list(selections),
    do: Enum.reduce(selections, preloads, &find_preloads(&1, fragments, &2))
  defp find_preloads(%{schema_node: %{identifier: i}}, _r, p) when i in @ignore_fields,
    do: p
  defp find_preloads(%{schema_node: %{identifier: i}, selections: s, argument_data: a}, f, p)
    when map_size(a) == 0, do: Map.put(p, i, find_preloads(s, f, %{}))
  defp find_preloads(%{schema_node: %{identifier: i}, selections: s, argument_data: a}, f, p),
    do: Map.put(p, i, find_preloads(s, f, %{args: a}))
  defp find_preloads(%Fragment.Spread{} = spread, fragments, preloads) do
    find_preloads(Map.get(fragments, spread.name).selections, fragments, preloads)
  end
  defp find_preloads(%Fragment.Inline{} = inline, fragments, preloads) do
    Enum.reduce(inline.selections, preloads, &find_preloads(&1, fragments, &2))
  end
end
