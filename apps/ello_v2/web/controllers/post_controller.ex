defmodule Ello.V2.PostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content

  def show(conn, %{"id" => id_or_slug}) do
    case Content.post(id_or_slug, conn.assigns[:current_user], conn.assigns[:allow_nsfw], conn.assigns[:allow_nudity]) do
      nil -> send_resp(conn, 404, "")
      post -> render(conn, post: post)
    end
  end
end
