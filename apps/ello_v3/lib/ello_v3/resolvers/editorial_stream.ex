defmodule Ello.V3.Resolvers.EditorialStream do
  alias Ello.Core.Discovery
  import Ello.V3.Resolvers.PaginationHelpers
  import Ello.V3.Resolvers.PostViewHelpers

  def call(_, args, _) do
    editorials = Discovery.editorials(Map.merge(args, %{preview: preview?(args)}))
    track(editorials, args, kind: "editorials")
    {:ok, %{
      editorials: editorials,
      next: next(args, editorials),
      is_last_page: is_last_page(args, editorials),
      kinds: [:curated_posts, :post, :internal, :external],
    }}
  end

  defp preview?(%{current_user: %{is_staff: true}, preview: true}), do: true
  defp preview?(_), do: false

  defp next(args, editorials) do
    last_editorial = List.last(editorials)
    if preview?(args) do
      last_editorial.preview_position
    else
      last_editorial.published_position
    end
  end
end
