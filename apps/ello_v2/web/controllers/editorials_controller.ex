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
    |> api_render_if_stale(data: editorials)
  end

  defp editorials(conn) do
    Discovery.editorials(standard_params(conn, %{preview: preview?(conn)}))
  end

  defp next_page_params(editorials, conn) do
    next = %{per_page: conn.params["per_page"] || 25}
    if preview?(conn) do
      Map.merge(next, %{
        before: List.last(editorials).preview_position,
        preview: true,
      })
    else
      Map.merge(next, %{
        before: List.last(editorials).published_position,
      })
    end
  end

  defp preview?(%{assigns: %{current_user: %{is_staff: true}}, params: %{"preview" => _}}), do: true
  defp preview?(_), do: false
end
