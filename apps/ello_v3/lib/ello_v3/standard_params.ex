defmodule Ello.V3.StandardParams do
  @max_page_size 100
  @default_page_size 25

  @doc """
  Extracts standard params from the resolver
  """
  def standard_params(%{context: context, arguments: args}, overrides \\ %{}) do
    Map.merge(%{
      current_user: context[:current_user],
      allow_nsfw:   context[:allow_nsfw],
      allow_nudity: context[:allow_nudity],
      before:       before(args),
      per_page:     per_page(args),
      page:         page(args),
    }, overrides)
  end

  defp before(%{before: before}), do: before
  defp before(_), do: nil

  defp page(%{page: ""}), do: 1
  defp page(%{page: nil}), do: 1
  defp page(%{page: page}), do: page
  defp page(_), do: 1

  defp per_page(%{per_page: nil}), do: @default_page_size
  defp per_page(%{per_page: ""}), do: @default_page_size
  defp per_page(%{per_page: per_page}) when per_page > @max_page_size, do: @max_page_size
  defp per_page(%{per_page: per_page}), do: per_page
  defp per_page(_), do: @default_page_size
end
