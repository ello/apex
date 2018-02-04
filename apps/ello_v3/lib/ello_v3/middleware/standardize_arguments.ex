defmodule Ello.V3.Middleware.StandardizeArguments do
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

  def preloads(%{path: [bp | _]}) do
    find_preloads(bp, %{})
  end

  # Root and query types are droped so we just get a list of the preloads
  @root_fields [:post, :posts]
  @query_types [:post_stream]

  # Ignores fields are typically nested json we just don't need to add to the preloads.
  @ignore_fields [
    :cover_image, :avatar, :external_links_list, # User
    :attachment, :repost_content, :summary, :content, # Post/Assets
    :tile_image, # Category
  ]

  def find_preloads(%{selections: []}, preloads),
    do: preloads
  def find_preloads(selections, preloads) when is_list(selections),
    do: Enum.reduce(selections, preloads, &find_preloads/2)
  def find_preloads(%{schema_node: %{type: t}, selections: s}, p) when t in @query_types,
    do: find_preloads(s, p)
  def find_preloads(%{schema_node: %{identifier: f}, selections: s}, p) when f in @root_fields,
    do: find_preloads(s, p)
  def find_preloads(%{schema_node: %{identifier: f}}, p) when f in @ignore_fields,
    do: p
  def find_preloads(%{schema_node: %{identifier: field}, selections: selections}, preloads),
    do: Map.put(preloads, field, find_preloads(selections, %{}))
end
