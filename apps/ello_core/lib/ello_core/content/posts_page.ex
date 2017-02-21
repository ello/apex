defmodule Ello.Core.Content.PostsPage do
  @type t :: %__MODULE__{}

  defstruct [
    :posts,
    :total_pages,
    :total_count,
    :total_pages_remaining,
    :before,
  ]
end
