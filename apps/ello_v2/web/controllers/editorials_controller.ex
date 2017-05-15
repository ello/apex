defmodule Ello.V2.EditorialController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Discovery

  @doc """
  GET /v2/editorials
  """
  def index(conn, params) do
    editorials = editorials(conn, params)

    conn
    |> track_post_view(Enum.map(editorials, &(&1.post)), stream_kind: "editorials")
    |> add_pagination_headers("/editorials", next_page_params(editorials, conn))
    |> api_render_if_stale(data: editorials)
  end

  defp editorials(conn, params) do
    current_user = current_user(conn)
    Discovery.editorials(%{
      current_user: current_user,
      allow_nsfw:   conn.assigns[:allow_nsfw],
      allow_nudity: conn.assigns[:allow_nudity],
      preview:      (params["preview"] == "true" && current_user.is_staff),
      before:       to_int(params["before"]),
      per_page:     to_int(params["per_page"]) || 25,
    })
  end

  defp to_int(nil), do: nil
  defp to_int(""), do: nil
  defp to_int(binary), do: String.to_integer(binary)

  defp next_page_params(editorials, conn) do
    next = %{per_page: conn.params["per_page"] || 25}
    if conn.params["preview"] == "true" && current_user(conn).is_staff do
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
end
