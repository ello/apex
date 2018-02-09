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

  defp preloads(%{definition: field, fragments: fragments}) do
    find_preloads(field, fragments, %{})
  end

  # Root and query types are droped so we just get a list of the preloads
  @root_fields [:post, :posts, :page_headers, :category_nav]
  @query_types [:post_stream]

  # Ignores fields are typically nested json we just don't need to add to the preloads.
  @ignore_fields [
    :cover_image, :avatar, :external_links_list, # User
    :attachment, :repost_content, :summary, :content, # Post/Assets
    :tile_image, # Category
    :cta_link, :image, # Promotionals/PagePromotional
  ]

  defp find_preloads(%{selections: []}, _fragments, preloads),
    do: preloads
  defp find_preloads(selections, fragments, preloads) when is_list(selections),
    do: Enum.reduce(selections, preloads, &find_preloads(&1, fragments, &2))
  defp find_preloads(%{schema_node: %{type: t}, selections: s}, r, p) when t in @query_types,
    do: find_preloads(s, r, p)
  defp find_preloads(%{schema_node: %{identifier: f}, selections: s}, r, p) when f in @root_fields,
    do: find_preloads(s, r, p)
  defp find_preloads(%{schema_node: %{identifier: f}}, _r, p) when f in @ignore_fields,
    do: p
  defp find_preloads(%{schema_node: %{identifier: field}, selections: selections}, fragments, preloads) do
    Map.put(preloads, field, find_preloads(selections, fragments, %{}))
  end
  defp find_preloads(%Fragment.Spread{} = spread, fragments, preloads) do
    find_preloads(Map.get(fragments, spread.name), fragments, preloads)
  end
end
