defmodule Ello.V3.Resolvers.CategoryPostStream do
  alias Ello.Stream
  alias Ello.Core.Discovery
  import Ello.V3.Resolvers.PaginationHelpers

  def call(_parent, %{id: id} = args, _resolution), do: resolve_category(id, args)
  def call(_parent, %{slug: slug} = args, _resolution), do: resolve_category(slug, args)

  defp resolve_category(id_or_slug, args) do
    case Ello.Core.Discovery.category(%{id_or_slug: id_or_slug}) do
      nil -> {:error, "Category not found"}
      category ->
        stream = Stream.fetch(Map.merge(args, %{
          keys:       [stream_key(category)],
          allow_nsfw: true,
        }))

        {:ok, %{
          id: category.id,
          slug: category.slug,
          posts: stream.posts,
          next: stream.before,
          is_last_page: is_last_page(args, stream.posts)
        }}
    end
  end

  defp stream_key(%Discovery.Category{roshi_slug: slug}), do: "categories:v1:#{slug}"
end

