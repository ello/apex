defmodule Ello.V3.Resolvers.SubscribedPostStream do
  alias Ello.Search.Post.Search
  alias Ello.Core.Discovery
  alias Ello.Stream
  import Ello.V3.Resolvers.PaginationHelpers
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_parent, %{current_user: nil}, _resolver), do: {:error, "Must be logged in"}
  def call(_, %{current_user: %{followed_category_ids: nil}}, _),
    do: {:ok, %{posts: [], next: nil, is_last_page: true}}
  def call(_, %{current_user: %{followed_category_ids: []}}, _),
    do: {:ok, %{posts: [], next: nil, is_last_page: true}}
  def call(_, %{kind: :recent}, _), do: {:error, "Recent has not been implemented"}
  def call(_, %{kind: :trending, current_user: current_user} = args, _) do
    search = Search.post_search(Map.merge(args, %{
      page:         trending_page_from_before(args),
      category_ids: current_user.followed_category_ids,
      trending:     true,
      within_days:  30,
      allow_nsfw:   false,
      images_only:  false,
    }))

    {:ok, %{
      posts: track(search.results, args, kind: :subscribed_trending),
      next: search.next_page,
      is_last_page: search.total_pages == search.page,
    }}
  end
  def call(_, %{kind: :featured, current_user: current_user} = args, _) do
    categories = Discovery.categories(%{ids: current_user.followed_category_ids})
    stream = Stream.fetch(Map.merge(args, %{
      keys:       Enum.map(categories, &stream_key/1),
      allow_nsfw: true,
    }))

    {:ok, %{
      posts: track(stream.posts, args, kind: :subscribed_featured),
      next:  stream.before,
      is_last_page: is_last_page(args, stream.posts)
    }}
  end

  defp stream_key(%Discovery.Category{roshi_slug: slug}), do: "categories:v1:#{slug}"
  defp stream_key(_), do: nil
end
