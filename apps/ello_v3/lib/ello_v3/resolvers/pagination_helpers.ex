defmodule Ello.V3.Resolvers.PaginationHelpers do

  def next_page([]), do: nil
  def next_page(posts) do
    DateTime.to_iso8601(List.last(posts).created_at)
  end

  @filter_slop 2 # Not last page if one blocked post gets filtered out
  def is_last_page(args, structs, filer_slop \\ @filter_slop)
  def is_last_page(_, [], _), do: true
  def is_last_page(%{per_page: requested}, structs, filter_slop) do
    if requested - filter_slop >= length(structs), do: true, else: false
  end

  def trending_page_from_before(%{before: nil}), do: 1
  def trending_page_from_before(%{before: i}) when is_integer(i), do: i
  def trending_page_from_before(%{before: str}), do: String.to_integer(str)
end
