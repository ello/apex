defmodule Ello.V3.Resolvers.SubscribedPostStream do
  alias Ello.Search.Post.Search
  import Ello.V3.Resolvers.PaginationHelpers

  def call(_parent, %{current_user: nil} = args, _resolver), do: {:error, "Must be logged in"}
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
      posts: search.results,
      next: search.next_page,
      is_last_page: search.total_pages == search.page,
    }}
  end
end
