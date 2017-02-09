defmodule Ello.V2.PostController do
  use Ello.V2.Web, :controller
  alias Ello.Core.Content

  def show(conn, %{"id" => id_or_slug}) do
    post = Content.post(id_or_slug, conn.assigns[:current_user])
    render(conn, post: post)
  end
end
