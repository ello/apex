defmodule Ello.V2.EditorialController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Discovery

  @doc """
  GET /v2/editorials
  """
  def index(conn, _params) do
    editorials = editorials(conn)

    conn
    |> track_post_view(editorials, stream_kind: "editorials")
    |> add_pagination_headers("/editorials", next_page_params(editorials, conn))
    |> last_page_header(editorials)
    |> api_render_if_stale(data: editorials)
  end

  defp editorials(conn) do
    Discovery.editorials(standard_params(conn, %{preview: preview?(conn)}))
  end

  defp next_page_params([], _), do: %{}
  defp next_page_params(editorials, conn) do
    last_editorial = List.last(editorials)
    next = %{per_page: per_page(conn)}
    if preview?(conn) do
      Map.merge(next, %{
        before: last_editorial.preview_position,
        preview: true,
      })
    else
      Map.merge(next, %{
        before: last_editorial.published_position,
      })
    end
  end

  defp last_page_header(conn, editorials) do
    editorials_count = length(editorials)
    per_page = per_page(conn)
    if editorials_count < per_page do
      put_resp_header(conn, "x-total-pages-remaining", "0")
    else
      put_resp_header(conn, "x-total-pages-remaining", "1")
    end
  end

  defp per_page(%{params: %{"per_page" => per_page}}) when is_binary(per_page), do: String.to_integer(per_page)
  defp per_page(%{params: %{"per_page" => per_page}}), do: per_page
  defp per_page(_), do: 25

  defp preview?(%{assigns: %{current_user: %{is_staff: true}}, params: %{"preview" => _}}), do: true
  defp preview?(_), do: false
end
