defmodule Ello.V3.Resolvers.CategoryPostStream do
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.Core.Discovery
  import Ello.V3.Resolvers.PaginationHelpers

  def call(_parent, %{id: id} = args, _resolution), do: resolve_category(id, args)
  def call(_parent, %{slug: slug} = args, _resolution), do: resolve_category(slug, args)

  defp resolve_category(id_or_slug, %{kind: :trending} = args) do
    case Discovery.category(%{id_or_slug: id_or_slug}) do
      nil -> {:error, "Category not found"}
      category ->
        search = Search.post_search(Map.merge(args, %{
          page:         trending_page_from_before(args),
          category:     category.id,
          trending:     true,
          within_days:  14,
          allow_nsfw:   false,
          allow_nudity: true,
          images_only:  false,
        }))

        {:ok, %{
          id:    category.id,
          slug:  category.slug,
          posts: search.results,
          next:  search.next_page,
          is_last_page: search.total_pages == search.page,
        }}
    end
  end
  defp resolve_category(id_or_slug, %{kind: :featured} = args) do
    case Discovery.category(%{id_or_slug: id_or_slug}) do
      nil -> {:error, "Category not found"}
      category ->
        stream = Stream.fetch(Map.merge(args, %{
          keys:       [stream_key(category)],
          allow_nsfw: true,
        }))

        {:ok, %{
          id:    category.id,
          slug:  category.slug,
          posts: stream.posts,
          next:  stream.before,
          is_last_page: is_last_page(args, stream.posts)
        }}
    end
  end
  defp resolve_category(_id_or_slug, %{kind: :recent}), do: {:error, "Recent has not been implemented"}

  defp stream_key(%Discovery.Category{roshi_slug: slug}), do: "categories:v1:#{slug}"
end

