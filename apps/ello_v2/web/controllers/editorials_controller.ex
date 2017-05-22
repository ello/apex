defmodule Ello.V2.EditorialController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Discovery

  @doc """
  GET /v2/editorials
  """
  def index(conn, _params) do
    editorials = editorials(conn)

    conn
    |> track_post_view(Enum.map(editorials, &(&1.post)), stream_kind: "editorials")
    |> add_pagination_headers("/editorials", next_page_params(editorials, conn))
    |> last_page_header(editorials)
    |> api_render_if_stale(data: editorials)
  end

  defp editorials(conn) do
    Discovery.editorials(standard_params(conn, %{preview: preview?(conn)}))
  end

  defp next_page_params(editorials, conn) do
    last_editorial = List.last(editorials)
    next = %{per_page: per_page(conn)}
    if preview?(conn) do
      before = case last_editorial do
        %{preview_position: preview_position} -> preview_position
        _ -> nil
      end
      Map.merge(next, %{
        before: before,
        preview: true,
      })
    else
      before = case last_editorial do
        %{published_position: published_position} -> published_position
        _ -> nil
      end
      Map.merge(next, %{
        before: before,
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
