defmodule Ello.V3.Resolvers.SearchUsers do
  alias Ello.Search.User.Search

  def call(_parent, %{username: true} = args, _resolver) do
    search = Search.username_search(Map.merge(args, %{terms: args.query}))
    {:ok, %{
      users: search.results,
      next: search.next_page,
      is_last_page: search.total_pages == search.page,
    }}
  end
  def call(_parent, %{username: false} = args, _resolver) do
    search = Search.user_search(Map.merge(args, %{terms: args.query}))
    {:ok, %{
      users: search.results,
      next: search.next_page,
      is_last_page: search.total_pages == search.page,
    }}
  end
end
