defmodule Ello.Serve.Webapp.DiscoverPostView do
  use Ello.Serve.Web, :view

  def posts(%{posts: posts}), do: posts
  def posts(%{results: posts}), do: posts

  def more_pages?(%{posts: posts, per_page: per_page}) do
    length(posts) >= per_page
  end
  def more_pages?(%{page: page, per_page: per_page}) do
    page < per_page
  end

  def next_page_url(path, %{before: before}) do
    webapp_url(path, %{before: before})
  end
  def next_page_url(path, %{next_page: next}) do
    webapp_url(path, %{before: next})
  end
end
