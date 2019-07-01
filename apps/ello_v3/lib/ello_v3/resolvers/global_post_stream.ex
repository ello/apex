defmodule Ello.V3.Resolvers.GlobalPostStream do
  alias Ello.Stream
  alias Ello.Search.Post.Search
  alias Ello.Core.Discovery
  alias Ello.Core.Contest
  import Ello.V3.Resolvers.PaginationHelpers
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_, %{kind: :trending} = args, _) do
    search = Search.post_search(Map.merge(args, %{
      page:         trending_page_from_before(args),
      trending:     true,
      within_days:  14,
      allow_nsfw:   false,
      images_only:  false,
    }))

    {:ok, %{
      posts: track(search.results, args, kind: :global_trending),
      next: search.next_page,
      is_last_page: search.total_pages == search.page,
    }}
  end

  def call(_, %{kind: :featured} = args, _) do
    categories = Task.async(Discovery, :categories, [%{primary: true, images: false}])
    invites = Task.async(Contest, :artist_invites, [%{for_discovery: true}])

    sources = Task.await(categories) ++ Task.await(invites)

    stream = Stream.fetch(Map.merge(args, %{
      keys:       Enum.map(sources, &Stream.key(&1, :featured)),
      allow_nsfw: true,
      require_cred: require_cred?(args),
    }))

    {:ok, %{
      posts: track(stream.posts, args, kind: :global_featured),
      next: stream.before,
      is_last_page: is_last_page(args, stream.posts)
    }}
  end

  def call(_, %{kind: :recent} = args, _) do
    stream = Stream.fetch(Map.merge(args, %{
      keys:       [Stream.key(:global_recent)],
      allow_nsfw: true,
      require_cred: require_cred?(args),
    }))

    {:ok, %{
      posts: track(stream.posts, args, kind: :global_recent),
      next: stream.before,
      is_last_page: is_last_page(args, stream.posts)
    }}
  end

  def call(_, %{kind: :shop} = args, _) do
    stream = Stream.fetch(Map.merge(args, %{
      keys:       [Stream.key(:global_shop)],
      allow_nsfw: true,
      require_cred: require_cred?(args),
    }))

    {:ok, %{
      posts: track(stream.posts, args, kind: :global_shop),
      next: stream.before,
      is_last_page: is_last_page(args, stream.posts)
    }}
  end

  # require the post author to have 100 total post views
  # staff accounts remove this requirement
  defp require_cred?(%{require_cred: true}), do: true
  defp require_cred?(%{require_cred: false}), do: false
  defp require_cred?(%{current_user: %{is_staff: true}}), do: false
  defp require_cred?(_), do: IO.inspect(true, label: "require_cred: ")
end
